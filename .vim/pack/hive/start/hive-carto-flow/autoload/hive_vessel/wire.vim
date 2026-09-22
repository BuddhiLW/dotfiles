vim9script
# hive-vessel Vim client: discovery, handshake, reconnect and HiveOp dispatch
# over the one JSON channel that also carries hive's :vim-channel natives.
# SPDX-License-Identifier: MIT

import autoload 'hive_vessel/ops.vim'

const WIRE = 1
const EDITOR = 'vim'

var channel: channel = null_channel
var session: string = ''
var address: string = ''
var retry_timer: number = 0
var last_error: string = ''

export def DiscoveryPath(): string
  const base = empty($XDG_RUNTIME_DIR) ? '/tmp' : $XDG_RUNTIME_DIR
  return get(g:, 'hive_vessel_discovery_dir', base .. '/hive-editor-wire') .. '/' .. EDITOR .. '.json'
enddef

export def ReadDiscovery(): dict<any>
  const path = DiscoveryPath()
  if !filereadable(path)
    return {}
  endif
  try
    return json_decode(join(readfile(path), "\n"))
  catch
    return {}
  endtry
enddef

# True on a discovered session (hello done) or a manual raw channel.
export def Connected(): bool
  return channel != null_channel && ch_status(channel) == 'open'
    && (session != '' || address != '')
enddef

def OnMessage(ch: channel, msg: any)
enddef

def OnClose(ch: channel)
  channel = null_channel
  session = ''
  address = ''
  ScheduleRetry()
enddef

def ScheduleRetry()
  if get(g:, 'hive_vessel_autoconnect', 1) && retry_timer == 0
    retry_timer = timer_start(get(g:, 'hive_vessel_retry_ms', 3000), (_) => {
      retry_timer = 0
      if !Connected()
        Connect('', true)
      endif
    })
  endif
enddef

def Open(addr: string): channel
  return ch_open(addr, {
    mode: 'json', waittime: 500, drop: 'never',
    callback: OnMessage, close_cb: OnClose})
enddef

# Manual fallback: a raw JSON channel to ADDR (host:port), no discovery, no
# hello. This is what hive-vessel.executor.vim-channel serves.
def ConnectRaw(addr: string, quiet: bool): bool
  Disconnect()
  const ch = Open(addr)
  if ch_status(ch) != 'open'
    last_error = 'connect failed on ' .. addr
    return false
  endif
  channel = ch
  address = addr
  session = ''
  last_error = ''
  if !quiet
    echomsg 'hive: connected to ' .. addr
  endif
  return true
enddef

# Connect through the discovery file, or to ADDR when given.
export def Connect(addr: string = '', quiet: bool = false): bool
  if addr != ''
    return ConnectRaw(addr, quiet)
  endif
  if address != ''
    Disconnect()
  endif
  if Connected()
    return true
  endif
  const doc = ReadDiscovery()
  if empty(doc) || get(doc, 'wire', 0) != WIRE
    last_error = 'no discovery file at ' .. DiscoveryPath()
    ScheduleRetry()
    return false
  endif
  const ch = Open('127.0.0.1:' .. doc.port)
  if ch_status(ch) != 'open'
    last_error = 'connect failed on port ' .. doc.port
    ScheduleRetry()
    return false
  endif
  const hello = {
    type: 'hello', wire: WIRE, token: doc.token, editor: EDITOR,
    instance: string(getpid()), capabilities: ops.Surfaces(), cwd: getcwd()}
  const reply = ch_evalexpr(ch, hello, {timeout: 3000})
  if type(reply) != v:t_dict || !get(reply, 'ok', false)
    last_error = 'hello refused: ' .. string(reply)
    ch_close(ch)
    ScheduleRetry()
    return false
  endif
  channel = ch
  session = reply.value.session
  address = ''
  last_error = ''
  if !quiet
    echomsg 'hive: connected, session ' .. session
  endif
  return true
enddef

export def Disconnect()
  if retry_timer != 0
    timer_stop(retry_timer)
    retry_timer = 0
  endif
  if channel != null_channel && ch_status(channel) == 'open'
    ch_close(channel)
  endif
  channel = null_channel
  session = ''
  address = ''
enddef

export def Start()
  if get(g:, 'hive_vessel_autoconnect', 1)
    Connect('', true)
  endif
enddef

export def Status(): dict<any>
  return {connected: Connected(), session: session, address: address,
    discovery: DiscoveryPath(), error: last_error}
enddef

# Events only exist on a discovered session; a raw channel has no peer for them.
export def SendEvent(name: string, data: dict<any>)
  if Connected() && session != ''
    ch_sendexpr(channel, {type: 'event', event: name, data: data}, {callback: (_, _) => 0})
  endif
enddef

export def ShowTerminal(id: string)
  ops.ShowTerminal(id)
enddef

export def Op(op: string, params: any): dict<any>
  const p = type(params) == v:t_dict ? params : {}
  try
    return ops.Dispatch(op, p)
  catch
    return {ok: false, error: {code: 'op/failed', message: v:exception}}
  endtry
enddef

# A Vim that already holds an older hive_vessel/ops.vim, loaded from another
# directory before this install, keeps it: Vim refuses to redefine an autoload
# function under a second path (E1073). Its OnEvent may have another signature
# (E118), so terminal_exit events stay undelivered until Vim restarts; every
# other op keeps working, and Status() names the reason.
try
  ops.OnEvent(SendEvent)
catch
  last_error = 'stale hive_vessel/ops.vim loaded; restart Vim (' .. v:exception .. ')'
  echohl WarningMsg
  echomsg 'hive-vessel: ' .. last_error
  echohl None
endtry
