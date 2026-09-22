" autoload/carto_flow.vim -- Carto Flow timeline over a Vim JSON channel
"
" The hive.carto-flow.vim server pushes channel commands:
"   ["call", "carto_flow#hello",  [{"server": ..., "frames": N}]]
"   ["call", "carto_flow#ingest", [{"index": I, "phase": ..., "line": ...,
"                                   "detail": [...], "frame": {...}}]]
"   ["call", "carto_flow#seek",   [{"index": I}]]
" A hello starts every connection and is followed by the replay of the whole
" timeline, so the frame list is rebuilt from it. Frames are keyed by index: a
" frame arriving twice replaces itself.
"
" Options:
"   g:carto_flow_port_file     port file (default $XDG_STATE_HOME/hive/carto-flow/vim.port)
"   g:carto_flow_port          fixed port, overrides the port file
"   g:carto_flow_reconnect_ms  reconnect interval in ms (default 2000)
"   g:carto_flow_waittime      ch_open waittime in ms (default 100)
"   g:carto_flow_max_frames    frames kept in this Vim (default 1000)
"   g:carto_flow_position      modifier placing the timeline window (default 'topleft')
"   g:carto_flow_follow_edits  open the edited file at the changed line on live frames (default 1)
"   g:carto_flow_auto_open     open the timeline, keeping focus, on the first live frame (default 0)
"   g:carto_flow_roots         directories relative frame paths are resolved against (cwd last)
"   g:carto_flow_code_position modifier for a code window when none exists (default 'botright')

let s:save_cpo = &cpo
set cpo&vim

let s:timeline_name = 'carto-flow://timeline'
let s:detail_name = 'carto-flow://frame'
let s:header_size = 3

let s:frames = get(s:, 'frames', [])
let s:cursor = get(s:, 'cursor', -1)
let s:follow = get(s:, 'follow', 1)
let s:channel = get(s:, 'channel', 0)
let s:address = get(s:, 'address', '')
let s:explicit_address = get(s:, 'explicit_address', '')
let s:timer = get(s:, 'timer', -1)
let s:wanted = get(s:, 'wanted', 0)
let s:connected = get(s:, 'connected', 0)
let s:received = get(s:, 'received', 0)
let s:server = get(s:, 'server', {})

" ---------------------------------------------------------------- connection

function! carto_flow#port_file() abort
  if exists('g:carto_flow_port_file')
    return g:carto_flow_port_file
  endif
  let l:state = empty($XDG_STATE_HOME) ? expand('~/.local/state') : $XDG_STATE_HOME
  return l:state . '/hive/carto-flow/vim.port'
endfunction

function! s:normalize_address(arg) abort
  let l:arg = trim(a:arg)
  if empty(l:arg)
    return ''
  endif
  return l:arg =~# ':' ? l:arg : '127.0.0.1:' . l:arg
endfunction

function! carto_flow#address() abort
  if !empty(s:explicit_address)
    return s:explicit_address
  endif
  let l:port = get(g:, 'carto_flow_port', 0)
  if l:port == 0
    let l:file = carto_flow#port_file()
    if !filereadable(l:file)
      return ''
    endif
    let l:port = str2nr(trim(get(readfile(l:file, '', 1), 0, '')))
  endif
  return l:port > 0 ? '127.0.0.1:' . l:port : ''
endfunction

" The server is hive-vessel's :vim-channel executor, which drives Vim with
" native JSON channel commands (:help channel-commands). Opening that channel
" needs nothing but ch_open, so this plugin opens its own and does not depend
" on which hive_vessel.vim is installed. The panel fallback still renders
" through autoload/hive_vessel.vim. The channel has no close_cb, so a drop is
" noticed by the reconnect timer, which keeps running while connected.

function! carto_flow#channel() abort
  return s:channel
endfunction

function! carto_flow#connected() abort
  let l:channel = carto_flow#channel()
  return type(l:channel) == v:t_channel && ch_status(l:channel) ==# 'open'
endfunction

function! carto_flow#connect(...) abort
  let s:wanted = 1
  if a:0 && !empty(a:1)
    let s:explicit_address = s:normalize_address(a:1)
  endif
  if carto_flow#connected()
    return 1
  endif
  let l:address = carto_flow#address()
  if empty(l:address)
    call s:schedule_reconnect()
    return 0
  endif
  try
    let s:channel = ch_open(l:address,
          \ {'mode': 'json', 'waittime': get(g:, 'carto_flow_waittime', 100)})
  catch
    let s:channel = 0
  endtry
  if !carto_flow#connected()
    call s:schedule_reconnect()
    return 0
  endif
  let s:address = l:address
  let s:connected = 1
  call s:schedule_reconnect()
  call s:render()
  return 1
endfunction

function! carto_flow#disconnect() abort
  let s:wanted = 0
  call s:stop_timer()
  if carto_flow#connected()
    call ch_close(carto_flow#channel())
  endif
  let s:connected = 0
  call s:render()
endfunction

function! s:schedule_reconnect() abort
  if s:timer != -1 || !s:wanted
    return
  endif
  let s:timer = timer_start(get(g:, 'carto_flow_reconnect_ms', 2000),
        \ function('s:reconnect_tick'), {'repeat': -1})
endfunction

function! s:stop_timer() abort
  if s:timer != -1
    call timer_stop(s:timer)
    let s:timer = -1
  endif
endfunction

function! s:reconnect_tick(timer) abort
  if !s:wanted
    call s:stop_timer()
    return
  endif
  if carto_flow#connected()
    let s:connected = 1
    return
  endif
  if s:connected
    " The connection was lost: say so before trying to get it back.
    let s:connected = 0
    call s:render()
  endif
  silent! call carto_flow#connect()
endfunction

" ------------------------------------------------------------------ messages

function! carto_flow#hello(info) abort
  " A hello precedes the replay of info.frames retained frames; only frames
  " indexed at or beyond that count are live and may be followed.
  let s:server = type(a:info) == v:t_dict ? a:info : {}
  let s:frames = []
  let s:cursor = -1
  let s:follow = 1
  call s:render()
endfunction

function! s:position(index) abort
  let l:i = len(s:frames) - 1
  while l:i >= 0
    if s:frames[l:i].index == a:index
      return l:i
    endif
    let l:i -= 1
  endwhile
  return -1
endfunction

function! carto_flow#ingest(msg) abort
  if type(a:msg) != v:t_dict || type(get(a:msg, 'index', v:null)) != v:t_number
    return
  endif
  let l:existing = s:position(a:msg.index)
  if l:existing >= 0
    let s:frames[l:existing] = a:msg
  else
    let l:pos = len(s:frames)
    while l:pos > 0 && s:frames[l:pos - 1].index > a:msg.index
      let l:pos -= 1
    endwhile
    call insert(s:frames, a:msg, l:pos)
    if !s:follow && s:cursor >= l:pos
      let s:cursor += 1
    endif
  endif
  let l:max = get(g:, 'carto_flow_max_frames', 1000)
  if len(s:frames) > l:max
    let l:drop = len(s:frames) - l:max
    call remove(s:frames, 0, l:drop - 1)
    let s:cursor = max([0, s:cursor - l:drop])
  endif
  if s:follow
    let s:cursor = len(s:frames) - 1
  endif
  let s:received += 1
  call s:render()
  if a:msg.index >= get(s:server, 'frames', 0)
    call s:on_live_frame(a:msg)
  endif
  if exists('#User#CartoFlowIngest')
    doautocmd <nomodeline> User CartoFlowIngest
  endif
endfunction

function! s:on_live_frame(msg) abort
  if get(g:, 'carto_flow_auto_open', 0) && bufwinid(bufnr(s:timeline_name)) == -1
    let l:back = win_getid()
    call carto_flow#open()
    call win_gotoid(l:back)
  endif
  if get(g:, 'carto_flow_follow_edits', 1)
        \ && index(['apply', 'succeeded'], get(a:msg, 'phase', '')) >= 0
    let l:loc = carto_flow#code_location(a:msg)
    if !empty(l:loc) && mode() ==# 'n'
      let l:back = win_getid()
      call s:show_code(l:loc)
      call win_gotoid(l:back)
    endif
  endif
endfunction

" :CartoFlowFollow [on|off] -- set g:carto_flow_follow_edits, or flip it with
" no argument. Returns the resulting state (1 on, 0 off); an unknown argument
" changes nothing.
function! carto_flow#follow_edits(...) abort
  let l:current = get(g:, 'carto_flow_follow_edits', 1) ? 1 : 0
  let l:arg = a:0 ? trim(a:1) : ''
  if empty(l:arg)
    let g:carto_flow_follow_edits = !l:current
  elseif l:arg ==# 'on'
    let g:carto_flow_follow_edits = 1
  elseif l:arg ==# 'off'
    let g:carto_flow_follow_edits = 0
  else
    echohl ErrorMsg
    echomsg 'carto-flow: :CartoFlowFollow takes on, off, or no argument'
    echohl None
    return l:current
  endif
  echomsg 'carto-flow: follow edits ' . (g:carto_flow_follow_edits ? 'on' : 'off')
  return g:carto_flow_follow_edits
endfunction

function! carto_flow#follow_complete(arglead, cmdline, cursorpos) abort
  return filter(['on', 'off'], 'v:val =~# "^" . a:arglead')
endfunction

" ---------------------------------------------------------------------- code

function! s:resolve_path(path) abort
  if type(a:path) != v:t_string || empty(a:path)
    return ''
  endif
  let l:path = expand(a:path)
  if l:path =~# '^/'
    return filereadable(l:path) ? l:path : ''
  endif
  for l:root in get(g:, 'carto_flow_roots', []) + [getcwd()]
    let l:candidate = fnamemodify(expand(l:root), ':p') . l:path
    if filereadable(l:candidate)
      return l:candidate
    endif
  endfor
  return ''
endfunction

" The new-file line of the first change in DIFF: the first hunk's +N start,
" advanced past its leading context lines to the first added or removed line.
" 1 when DIFF has no hunk.
function! carto_flow#first_changed_line(diff) abort
  let l:line = 0
  for l:text in split(type(a:diff) == v:t_string ? a:diff : '', "\n")
    if l:line == 0
      let l:hunk = matchlist(l:text, '^@@ -\d\+\%(,\d\+\)\= +\(\d\+\)')
      if !empty(l:hunk)
        let l:line = str2nr(l:hunk[1])
      endif
    elseif l:text =~# '^[+-]'
      return l:line
    elseif l:text =~# '^@@'
      return l:line
    else
      let l:line += 1
    endif
  endfor
  return l:line > 0 ? l:line : 1
endfunction

" Where a frame's change lives: the first readable affected path, at the first
" changed line of the frame's diff (line 1 without a diff). {} when no affected
" path resolves to a readable file.
function! carto_flow#code_location(msg) abort
  let l:frame = type(get(a:msg, 'frame', 0)) == v:t_dict ? a:msg.frame : {}
  let l:paths = get(l:frame, 'affected/paths', [])
  let l:file = ''
  for l:path in (type(l:paths) == v:t_list ? l:paths : [])
    let l:file = s:resolve_path(l:path)
    if !empty(l:file)
      break
    endif
  endfor
  if empty(l:file)
    return {}
  endif
  return {'file': l:file,
        \ 'line': carto_flow#first_changed_line(get(l:frame, 'frame/diff', ''))}
endfunction

function! s:code_window() abort
  for l:nr in range(1, winnr('$'))
    if bufname(winbufnr(l:nr)) !~# '^carto-flow://'
      return win_getid(l:nr)
    endif
  endfor
  return 0
endfunction

" Show LOC in a window that is not a carto-flow buffer, creating one when the
" timeline and detail are all there is. Leaves focus in that window.
function! s:show_code(loc) abort
  let l:win = s:code_window()
  if l:win
    call win_gotoid(l:win)
  else
    execute 'silent ' . get(g:, 'carto_flow_code_position', 'botright') . ' new'
  endif
  execute 'silent keepjumps hide edit ' . fnameescape(a:loc.file)
  call cursor(a:loc.line, 1)
  normal! zz
endfunction

function! carto_flow#open_code(...) abort
  let l:i = a:0 ? a:1 : s:cursor
  if l:i < 0 || l:i >= len(s:frames)
    return 0
  endif
  let l:loc = carto_flow#code_location(s:frames[l:i])
  if empty(l:loc)
    echomsg 'carto-flow: no readable file for frame #' . s:frames[l:i].index
    return 0
  endif
  call s:show_code(l:loc)
  return 1
endfunction

" ------------------------------------------------------------------- queries

function! carto_flow#frames() abort
  return deepcopy(s:frames)
endfunction

function! carto_flow#status() abort
  return {
        \ 'connected': carto_flow#connected(),
        \ 'address': s:address,
        \ 'frames': len(s:frames),
        \ 'received': s:received,
        \ 'cursor': s:cursor,
        \ 'server': s:server,
        \ }
endfunction

function! carto_flow#lines() abort
  let l:state = carto_flow#connected() ? 'connected ' . s:address : 'disconnected'
  let l:count = len(s:frames)
  let l:lines = [
        \ "Carto Flow -- this session's Carto changes",
        \ printf('%d frame%s  [%s]', l:count, l:count == 1 ? '' : 's', l:state),
        \ repeat('-', 72),
        \ ]
  if empty(s:frames)
    call add(l:lines, 'Waiting for Carto operations...')
    return l:lines
  endif
  let l:i = 0
  for l:msg in s:frames
    call add(l:lines, (l:i == s:cursor ? '> ' : '  ') . get(l:msg, 'line', ''))
    let l:i += 1
  endfor
  return l:lines
endfunction

" ---------------------------------------------------------------- navigation

function! s:move(delta) abort
  if empty(s:frames)
    return
  endif
  let l:current = s:cursor < 0 ? len(s:frames) - 1 : s:cursor
  let s:cursor = max([0, min([len(s:frames) - 1, l:current + a:delta])])
  let s:follow = s:cursor == len(s:frames) - 1
  call s:render()
  call s:refresh_detail()
endfunction

function! carto_flow#next() abort
  call s:move(v:count1)
endfunction

function! carto_flow#previous() abort
  call s:move(-v:count1)
endfunction

function! carto_flow#latest() abort
  let s:follow = 1
  let s:cursor = len(s:frames) - 1
  call s:render()
  call s:refresh_detail()
endfunction

" Core's timeline cursor moved (next!, previous!, latest! from any client): put
" this Vim's cursor on the same frame, keeping follow on only at the newest one.
" An index this Vim does not hold is ignored.
function! carto_flow#seek(msg) abort
  if type(a:msg) != v:t_dict || type(get(a:msg, 'index', v:null)) != v:t_number
    return
  endif
  let l:pos = s:position(a:msg.index)
  if l:pos < 0
    return
  endif
  let s:cursor = l:pos
  let s:follow = s:cursor == len(s:frames) - 1
  call s:render()
  call s:refresh_detail()
endfunction

function! carto_flow#clear() abort
  let s:frames = []
  let s:cursor = -1
  let s:follow = 1
  call s:render()
endfunction

" ------------------------------------------------------------------- buffers

function! s:render() abort
  let l:buf = bufnr(s:timeline_name)
  if l:buf == -1 || !bufloaded(l:buf)
    return
  endif
  let l:lines = carto_flow#lines()
  call setbufvar(l:buf, '&modifiable', 1)
  call setbufline(l:buf, 1, l:lines)
  let l:total = len(getbufline(l:buf, 1, '$'))
  if l:total > len(l:lines)
    silent call deletebufline(l:buf, len(l:lines) + 1, '$')
  endif
  call setbufvar(l:buf, '&modifiable', 0)
  if s:cursor >= 0
    let l:lnum = s:header_size + 1 + s:cursor
    for l:win in win_findbuf(l:buf)
      call win_execute(l:win, 'call cursor(' . l:lnum . ', 1)')
    endfor
  endif
endfunction

function! s:setup_timeline() abort
  setlocal buftype=nofile bufhidden=hide noswapfile nobuflisted
  setlocal nowrap nonumber norelativenumber nospell cursorline
  setlocal nomodifiable
  setlocal filetype=cartoflow
  nnoremap <buffer> <silent> ]f :<C-u>call carto_flow#next()<CR>
  nnoremap <buffer> <silent> [f :<C-u>call carto_flow#previous()<CR>
  nnoremap <buffer> <silent> n :<C-u>call carto_flow#next()<CR>
  nnoremap <buffer> <silent> p :<C-u>call carto_flow#previous()<CR>
  nnoremap <buffer> <silent> G :<C-u>call carto_flow#latest()<CR>
  nnoremap <buffer> <silent> <CR> :<C-u>call carto_flow#detail_at_line(line('.'))<CR>
  nnoremap <buffer> <silent> o :<C-u>call carto_flow#open_code_at_line(line('.'))<CR>
  nnoremap <buffer> <silent> q :<C-u>call carto_flow#close()<CR>
endfunction

" The detail buffer pages frames with the timeline's keys; moving re-renders
" the open detail in place (s:refresh_detail), so focus stays here.
function! s:setup_detail() abort
  setlocal buftype=nofile bufhidden=hide noswapfile nobuflisted nowrap
  nnoremap <buffer> <silent> ]f :<C-u>call carto_flow#next()<CR>
  nnoremap <buffer> <silent> [f :<C-u>call carto_flow#previous()<CR>
  nnoremap <buffer> <silent> n :<C-u>call carto_flow#next()<CR>
  nnoremap <buffer> <silent> p :<C-u>call carto_flow#previous()<CR>
  nnoremap <buffer> <silent> G :<C-u>call carto_flow#latest()<CR>
  nnoremap <buffer> <silent> o :<C-u>call carto_flow#open_code()<CR>
  nnoremap <buffer> <silent> q :<C-u>close<CR>
endfunction

function! s:detail_lines(i) abort
  let l:msg = s:frames[a:i]
  return get(l:msg, 'detail', [get(l:msg, 'line', '')])
endfunction

function! s:refresh_detail() abort
  let l:buf = bufnr(s:detail_name)
  if l:buf == -1 || bufwinid(l:buf) == -1 || s:cursor < 0 || s:cursor >= len(s:frames)
    return
  endif
  call setbufvar(l:buf, '&modifiable', 1)
  silent call deletebufline(l:buf, 1, '$')
  call setbufline(l:buf, 1, s:detail_lines(s:cursor))
  call setbufvar(l:buf, '&modifiable', 0)
endfunction

function! carto_flow#open_code_at_line(lnum) abort
  let l:i = a:lnum - s:header_size - 1
  if l:i >= 0 && l:i < len(s:frames)
    let s:cursor = l:i
    let s:follow = s:cursor == len(s:frames) - 1
    call s:render()
  endif
  return carto_flow#open_code(s:cursor)
endfunction

function! carto_flow#open(...) abort
  call call('carto_flow#connect', a:000)
  let l:buf = bufnr(s:timeline_name)
  let l:win = bufwinid(l:buf)
  if l:win != -1
    call win_gotoid(l:win)
  elseif l:buf != -1
    execute 'silent ' . get(g:, 'carto_flow_position', 'topleft') . ' sbuffer ' . l:buf
  else
    execute 'silent ' . get(g:, 'carto_flow_position', 'topleft') . ' new'
    execute 'silent file ' . fnameescape(s:timeline_name)
    call s:setup_timeline()
  endif
  call s:render()
endfunction

function! carto_flow#close() abort
  if winnr('$') > 1
    close
  else
    enew
  endif
endfunction

function! carto_flow#detail_at_line(lnum) abort
  let l:i = a:lnum - s:header_size - 1
  if l:i >= 0 && l:i < len(s:frames)
    let s:cursor = l:i
    let s:follow = s:cursor == len(s:frames) - 1
    call s:render()
  endif
  call carto_flow#detail(s:cursor)
endfunction

function! carto_flow#detail(...) abort
  let l:i = a:0 ? a:1 : s:cursor
  if l:i < 0 || l:i >= len(s:frames)
    return
  endif
  let l:lines = s:detail_lines(l:i)
  let l:buf = bufnr(s:detail_name)
  let l:win = bufwinid(l:buf)
  if l:win != -1
    call win_gotoid(l:win)
  elseif l:buf != -1
    execute 'silent belowright sbuffer ' . l:buf
  else
    execute 'silent belowright new'
    execute 'silent file ' . fnameescape(s:detail_name)
  endif
  call s:setup_detail()
  setlocal modifiable
  silent %delete _
  call setline(1, l:lines)
  setlocal nomodifiable
  setlocal filetype=diff
endfunction

" ---------------------------------------------------------------- toggling

" Show or hide the timeline. The buffer and its frames outlive a hidden
" window, so the next toggle shows the same timeline rather than an empty one.
" Returns 1 when the timeline is visible afterwards.
function! carto_flow#toggle(...) abort
  let l:win = bufwinid(bufnr(s:timeline_name))
  if l:win == -1
    call call('carto_flow#open', a:000)
    return 1
  endif
  if win_getid() == l:win
    call carto_flow#close()
  else
    let l:back = win_getid()
    call win_gotoid(l:win)
    call carto_flow#close()
    if win_id2win(l:back) > 0
      call win_gotoid(l:back)
    endif
  endif
  return 0
endfunction

" Open the timeline and put the cursor on the newest frame, following from
" there.
function! carto_flow#show_latest(...) abort
  call call('carto_flow#open', a:000)
  call carto_flow#latest()
  return carto_flow#status().cursor
endfunction

" Disconnect when connected, connect when not. A disconnect also stops the
" reconnect timer, so this is the off switch rather than a dropped channel.
function! carto_flow#toggle_connection(...) abort
  if carto_flow#connected()
    call carto_flow#disconnect()
    echomsg 'carto-flow: disconnected'
    return 0
  endif
  let l:ok = call('carto_flow#connect', a:000)
  echomsg 'carto-flow: ' . (l:ok ? 'connected ' . carto_flow#status().address
        \ : 'waiting for hive')
  return l:ok
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
