vim9script
# hive-vessel: hive editor wire v1 op handlers for Vim. Op names are the
# hive-spi port verbs.
# SPDX-License-Identifier: MIT

var terms: dict<number> = {}
var handlers: dict<func(dict<any>): dict<any>> = {}
var EventSink: func = (_, _) => 0

# Register the sink events (terminal_exit) go to; wire.vim installs SendEvent.
export def OnEvent(F: func)
  EventSink = F
enddef

export def Surfaces(): list<string>
  return has('terminal') ? ['editor', 'buffer', 'terminal'] : ['editor', 'buffer']
enddef

def Ok(value: any): dict<any>
  return {ok: true, value: value}
enddef

def Err(code: string, message: string = ''): dict<any>
  return empty(message)
    ? {ok: false, error: {code: code}}
    : {ok: false, error: {code: code, message: message}}
enddef

def Json(value: any): any
  const t = type(value)
  if t == v:t_func || t == v:t_job || t == v:t_channel || t == v:t_blob
    return string(value)
  elseif t == v:t_float && (isnan(value) || isinf(value) != 0)
    return string(value)
  elseif t == v:t_list
    return mapnew(value, (_, v) => Json(v))
  elseif t == v:t_dict
    return mapnew(value, (_, v) => Json(v))
  endif
  return value
enddef

def BufEntry(b: dict<any>): dict<any>
  return {
    bufnr: b.bufnr,
    name: b.name,
    file: empty(b.name) ? v:null : fnamemodify(b.name, ':p'),
    modified: b.changed != 0,
    listed: b.listed != 0,
    buftype: getbufvar(b.bufnr, '&buftype'),
    filetype: getbufvar(b.bufnr, '&filetype'),
    lines: b.linecount}
enddef

def CurrentBuffer(): dict<any>
  var entry = BufEntry(getbufinfo(bufnr('%'))[0])
  return extend(entry, {line: line('.'), col: col('.'), mode: mode()})
enddef

def Text(value: any): string
  return type(value) == v:t_string ? value : string(value)
enddef

def ResolveBuf(name: any): number
  if type(name) == v:t_number
    return bufexists(name) ? name : -1
  endif
  const s = Text(name)
  return s =~ '^\d\+$' ? str2nr(s) : bufnr(s)
enddef

def ProjectRoot(): any
  const start = empty(expand('%:p')) ? getcwd() : expand('%:p:h')
  for marker in get(g:, 'hive_root_markers', ['.hive-project.edn', 'deps.edn', '.git'])
    const dir = finddir(marker, start .. ';')
    if !empty(dir)
      return fnamemodify(dir, ':p:h:h')
    endif
    const file = findfile(marker, start .. ';')
    if !empty(file)
      return fnamemodify(file, ':p:h')
    endif
  endfor
  return v:null
enddef

def EditorEval(p: dict<any>): dict<any>
  const code = get(p, 'code', '')
  if type(code) != v:t_string || empty(code)
    return Err('op/failed', 'code is required')
  endif
  const vim9 = get(p, 'syntax', 'legacy') == 'vim9'
  if get(p, 'mode', 'expr') == 'ex'
    return Ok(vim9 ? execute(code) : execute('legacy ' .. code))
  endif
  if vim9
    return Ok(Json(eval(code)))
  endif
  g:Hive_eval_code = code
  var value: any = v:null
  try
    legacy let g:Hive_eval_result = eval(g:Hive_eval_code)
    value = Json(g:Hive_eval_result)
  catch
    unlet! g:Hive_eval_code g:Hive_eval_result
    return Err('op/failed', v:exception)
  endtry
  unlet! g:Hive_eval_code g:Hive_eval_result
  return Ok(value)
enddef

def EditorNotify(p: dict<any>): dict<any>
  const msg = Text(get(p, 'message', ''))
  const level = get(p, 'level', 'info')
  execute 'echohl ' .. (level == 'error' ? 'ErrorMsg' : level == 'warn' ? 'WarningMsg' : 'None')
  echomsg 'hive: ' .. msg
  echohl None
  if has('popupwin')
    popup_notification('hive: ' .. msg, {time: 4000, highlight: level == 'error' ? 'ErrorMsg' : 'WarningMsg'})
  endif
  return Ok(v:true)
enddef

def EditorStatus(p: dict<any>): dict<any>
  return Ok({
    editor: 'vim', version: v:version, pid: getpid(), cwd: getcwd(),
    buffer: CurrentBuffer(), servername: v:servername})
enddef

def EditorCapabilities(p: dict<any>): dict<any>
  return Ok({
    surfaces: Surfaces(),
    ops: sort(keys(handlers)),
    features: {terminal: has('terminal') != 0, popupwin: has('popupwin') != 0}})
enddef

def ListBuffers(p: dict<any>): dict<any>
  return Ok(mapnew(getbufinfo({buflisted: 1}), (_, b) => BufEntry(b)))
enddef

def CurrentBufferOp(p: dict<any>): dict<any>
  return Ok(CurrentBuffer())
enddef

def BufferInfo(p: dict<any>): dict<any>
  const nr = ResolveBuf(get(p, 'buffer_name', ''))
  if nr < 1
    return Err('op/failed', 'no buffer ' .. string(get(p, 'buffer_name', '')))
  endif
  return Ok(BufEntry(getbufinfo(nr)[0]))
enddef

def SpecialBuffers(p: dict<any>): dict<any>
  return Ok(mapnew(filter(getbufinfo(), (_, b) => !empty(getbufvar(b.bufnr, '&buftype'))), (_, b) => BufEntry(b)))
enddef

def SwitchBuffer(p: dict<any>): dict<any>
  const nr = ResolveBuf(get(p, 'buffer', ''))
  if nr < 1
    return Err('op/failed', 'no buffer ' .. string(get(p, 'buffer', '')))
  endif
  execute 'hide buffer ' .. nr
  return Ok(CurrentBuffer())
enddef

def FindFile(p: dict<any>): dict<any>
  const file = get(p, 'file', '')
  if type(file) != v:t_string || empty(file)
    return Err('op/failed', 'file is required')
  endif
  execute 'hide edit ' .. fnameescape(file)
  return Ok(CurrentBuffer())
enddef

def SaveBuffers(p: dict<any>): dict<any>
  if get(p, 'all', v:false) == v:true
    wall
  else
    write
  endif
  return Ok(v:true)
enddef

def GotoLine(p: dict<any>): dict<any>
  const lnum = get(p, 'line', 0)
  if type(lnum) != v:t_number || lnum < 1
    return Err('op/failed', 'line must be a positive integer')
  endif
  cursor(lnum, 1)
  normal! zz
  return Ok(CurrentBuffer())
enddef

def InsertText(p: dict<any>): dict<any>
  const text = get(p, 'text', '')
  if type(text) != v:t_string
    return Err('op/failed', 'text must be a string')
  endif
  const lnum = line('.')
  const byte = col('.') - 1
  const cur = getline(lnum)
  var parts = split(text, "\n", 1)
  const last = len(parts) - 1
  const end_col = strlen(parts[last]) + (last == 0 ? byte : 0)
  parts[0] = strpart(cur, 0, byte) .. parts[0]
  parts[last] = parts[last] .. strpart(cur, byte)
  setline(lnum, parts[0])
  if last > 0
    append(lnum, parts[1 :])
  endif
  cursor(lnum + last, end_col + 1)
  return Ok({line: lnum + last, col: end_col + 1})
enddef

def RecentFiles(p: dict<any>): dict<any>
  const limit = get(p, 'limit', 50)
  return Ok(filter(copy(v:oldfiles), (_, f) => filereadable(expand(f)))[: limit - 1])
enddef

def ProjectRootOp(p: dict<any>): dict<any>
  return Ok({root: ProjectRoot()})
enddef

def EditorContext(p: dict<any>): dict<any>
  return Ok({
    buffer: CurrentBuffer(), project_root: ProjectRoot(), cwd: getcwd(),
    buffers: len(getbufinfo({buflisted: 1})), terminals: keys(terms)})
enddef

def TermBuf(p: dict<any>): number
  const id = get(p, 'id', '')
  return has_key(terms, id) && bufexists(terms[id]) ? terms[id] : -1
enddef

def TerminalSpawn(p: dict<any>): dict<any>
  if !has('terminal')
    return Err('op/unsupported', 'vim built without +terminal')
  endif
  const id = get(p, 'id', '')
  if type(id) != v:t_string || empty(id)
    return Err('op/failed', 'id is required')
  endif
  if TermBuf(p) > 0
    return Err('op/failed', 'terminal ' .. id .. ' already exists')
  endif
  var opts: dict<any> = {term_name: 'hive:' .. id, hidden: !get(p, 'show', v:false),
    term_finish: 'open', term_kill: 'kill',
    exit_cb: (_, status) => EventSink('terminal_exit', {id: id, status: status})}
  if type(get(p, 'cwd', v:null)) == v:t_string && isdirectory(p.cwd)
    opts.cwd = p.cwd
  endif
  if type(get(p, 'env', v:null)) == v:t_dict
    opts.env = p.env
  endif
  const cmd = get(p, 'cmd', [&shell])
  const buf = term_start(cmd, opts)
  if buf < 1
    return Err('op/failed', 'term_start failed for ' .. string(cmd))
  endif
  terms[id] = buf
  return Ok({terminal: buf})
enddef

def TerminalDispatch(p: dict<any>): dict<any>
  const buf = TermBuf(p)
  if buf < 1
    return Err('op/failed', 'no terminal ' .. string(get(p, 'id', '')))
  endif
  term_sendkeys(buf, get(p, 'text', '') .. "\r")
  return Ok(v:true)
enddef

def TerminalRead(p: dict<any>): dict<any>
  const buf = TermBuf(p)
  if buf < 1
    return Err('op/failed', 'no terminal ' .. string(get(p, 'id', '')))
  endif
  var lines = getbufline(buf, 1, '$')
  while !empty(lines) && lines[-1] =~ '^\s*$'
    remove(lines, -1)
  endwhile
  const limit = get(p, 'lines', 200)
  return Ok({lines: len(lines) > limit ? lines[-limit :] : lines})
enddef

def TerminalStatus(p: dict<any>): dict<any>
  const buf = TermBuf(p)
  if buf < 1
    return Err('op/failed', 'no terminal ' .. string(get(p, 'id', '')))
  endif
  const st = term_getstatus(buf)
  return Ok({status: st =~ 'running' ? 'running' : st =~ 'finished' ? 'finished' : 'dead', raw: st})
enddef

def TerminalKill(p: dict<any>): dict<any>
  const buf = TermBuf(p)
  if buf < 1
    return Err('op/failed', 'no terminal ' .. string(get(p, 'id', '')))
  endif
  const job = term_getjob(buf)
  if job != null_job && job_status(job) == 'run'
    job_stop(job, 'kill')
  endif
  execute 'bwipeout! ' .. buf
  remove(terms, p.id)
  return Ok(v:true)
enddef

def TerminalInterrupt(p: dict<any>): dict<any>
  const buf = TermBuf(p)
  if buf < 1
    return Err('op/failed', 'no terminal ' .. string(get(p, 'id', '')))
  endif
  term_sendkeys(buf, get(p, 'keys', "\<Esc>"))
  return Ok(v:true)
enddef

handlers = {
  'editor-eval': EditorEval,
  'editor-notify': EditorNotify,
  'editor-status': EditorStatus,
  'editor-capabilities': EditorCapabilities,
  'list-buffers': ListBuffers,
  'current-buffer': CurrentBufferOp,
  'buffer-info': BufferInfo,
  'special-buffers': SpecialBuffers,
  'switch-buffer': SwitchBuffer,
  'find-file': FindFile,
  'save-buffers': SaveBuffers,
  'goto-line': GotoLine,
  'insert-text': InsertText,
  'recent-files': RecentFiles,
  'project-root': ProjectRootOp,
  'editor-context': EditorContext,
  'terminal-spawn': TerminalSpawn,
  'terminal-dispatch': TerminalDispatch,
  'terminal-read': TerminalRead,
  'terminal-status': TerminalStatus,
  'terminal-kill': TerminalKill,
  'terminal-interrupt': TerminalInterrupt,
}

export def Ops(): list<string>
  return sort(keys(handlers))
enddef

export def Dispatch(op: string, p: dict<any>): dict<any>
  if !has_key(handlers, op)
    return Err('op/unsupported', op)
  endif
  return handlers[op](p)
enddef

export def ShowTerminal(id: string)
  const buf = TermBuf({id: id})
  if buf > 0
    execute 'botright sbuffer ' .. buf
  endif
enddef
