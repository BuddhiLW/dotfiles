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
"   g:carto_flow_layout        panel layout: left|right|top|bottom-N/D or classic
"                              (default 'left-1/3'; 'classic' when g:carto_flow_position is set)
"   g:carto_flow_layouts       layouts v / V / :CartoFlowLayout cycle through
"                              (default ['left-1/3', 'left-1/2', 'bottom-1/3', 'bottom-1/2'])
"   g:carto_flow_timeline_share share of the panel the timeline takes beside the detail (default 0.4)
"   g:carto_flow_position      modifier placing the timeline window in the classic layout (default 'topleft')
"   g:carto_flow_follow_edits  open the edited file at the changed line on live frames (default 1)
"   g:carto_flow_auto_open     open the timeline, keeping focus, on the first live frame (default 0)
"   g:carto_flow_roots         directories relative frame paths are resolved against (cwd last)
"   g:carto_flow_code_position modifier for a code window when none exists (default 'botright')

let s:save_cpo = &cpo
set cpo&vim

let s:timeline_name = 'carto-flow://timeline'
let s:detail_name = 'carto-flow://frame'
let s:header_size = 3

" Re-sourcing this file keeps its s: state. Sourcing it from another path (a
" hot reload from the hive-extracted runtime into a Vim that loaded an older
" copy elsewhere) starts a fresh script whose carto_flow# functions replace
" the old ones: before they do, take the old script's channel and frames over
" through its public functions, so the Vim keeps its one connection.
if !exists('s:frames') && exists('*carto_flow#frames')
  let s:handoff = {'frames': carto_flow#frames(),
        \ 'channel': exists('*carto_flow#channel') ? carto_flow#channel() : 0,
        \ 'status': exists('*carto_flow#status') ? carto_flow#status() : {}}
  let s:frames = s:handoff.frames
  let s:cursor = get(s:handoff.status, 'cursor', len(s:frames) - 1)
  let s:follow = s:cursor == len(s:frames) - 1
  let s:channel = s:handoff.channel
  let s:address = get(s:handoff.status, 'address', '')
  let s:received = get(s:handoff.status, 'received', 0)
  let s:server = get(s:handoff.status, 'server', {})
  let s:wanted = type(s:channel) == v:t_channel
  let s:connected = s:wanted && ch_status(s:channel) ==# 'open'
  unlet s:handoff
endif

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

" Diff walk state: stops navigation
let s:frame_stops = get(s:, 'frame_stops', {})
let s:stops = get(s:, 'stops', [])
" An old script at another path exposes its frames; reconstruct its walk.
if empty(s:frame_stops) && !empty(s:frames)
  for s:frame in s:frames
    let s:frame_stops[s:frame.index] = get(s:frame, 'stops', [])
    call extend(s:stops, s:frame_stops[s:frame.index])
  endfor
  unlet s:frame
endif
let s:stop_cursor = get(s:, 'stop_cursor', -1)
let s:stop_mode = get(s:, 'stop_mode', 0)
let s:stop_decorations = get(s:, 'stop_decorations', {})
let s:code_windows = get(s:, 'code_windows', [])
let s:code_page = get(s:, 'code_page', 0)
let s:code_view = get(s:, 'code_view', 0)
let s:sign_id = get(s:, 'sign_id', 0)

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
  call carto_flow#exit_stop_mode()
  let s:frame_stops = {}
  let s:stops = []
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
  let s:frame_stops = {}
  let s:stops = []
  for l:frame in s:frames
    let s:frame_stops[l:frame.index] = get(l:frame, 'stops', [])
    call extend(s:stops, s:frame_stops[l:frame.index])
  endfor
  if s:stop_cursor >= len(s:stops)
    let s:stop_cursor = len(s:stops) - 1
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
  let l:view = s:code_view
  call s:clear_stop_decorations()
  let s:stop_mode = 0
  let l:current = s:cursor < 0 ? len(s:frames) - 1 : s:cursor
  let s:cursor = max([0, min([len(s:frames) - 1, l:current + a:delta])])
  let s:follow = s:cursor == len(s:frames) - 1
  call s:render()
  call s:refresh_detail()
  if l:view
    call carto_flow#code_view(s:cursor)
  endif
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
  if s:code_view
    call carto_flow#code_view(s:cursor)
  endif
endfunction

" --------------------------------------------------------- diff walk: stops

" Clear decorations on the buffer they were attached to, not the current buffer.
function! s:clear_stop_decorations() abort
  for l:key in keys(s:stop_decorations)
    let l:buf = str2nr(l:key)
    if l:buf <= 0
      continue
    endif
    if bufexists(l:buf) && has('textprop')
      for l:type in ['cartoFlowAddLine', 'cartoFlowDelText']
        call prop_remove({'type': l:type, 'all': 1, 'bufnr': l:buf})
      endfor
    endif
    if has('signs')
      execute 'sign unplace * group=cartoflow buffer=' . l:buf
    endif
    for l:item in get(s:stop_decorations[l:key], 'matches', [])
      if win_id2win(l:item[0]) > 0
        silent! call matchdelete(l:item[1], l:item[0])
      endif
    endfor
  endfor
  let s:stop_decorations = {}
endfunction

function! carto_flow#highlights() abort
  " Derive only the background of additions; never override syntax foreground.
  let l:add = synIDtrans(hlID('DiffAdd'))
  let l:gui = synIDattr(l:add, 'bg#')
  let l:cterm = synIDattr(l:add, 'bg', 'cterm')
  let l:bg = (l:gui =~# '^#[0-9a-fA-F]\{6}$' ? ' guibg=' . l:gui : '')
        \ . (l:cterm =~# '^\d\+$' ? ' ctermbg=' . l:cterm : '')
  if empty(l:bg)
    let l:bg = ' guibg=#243d32 ctermbg=darkgreen'
  endif
  execute 'hi def cartoFlowAddLine' . l:bg
  hi def link cartoFlowAddSign DiffAdd
  hi def link cartoFlowDelSign DiffDelete
  let l:del = synIDtrans(hlID('DiffDelete'))
  let l:fg = synIDattr(l:del, 'fg#')
  let l:fg = l:fg =~# '^#[0-9a-fA-F]\{6}$' ? l:fg : synIDattr(synIDtrans(hlID('Comment')), 'fg#')
  execute 'hi def cartoFlowDelText gui=italic cterm=italic'
        \ . (l:fg =~# '^#[0-9a-fA-F]\{6}$' ? ' guifg=' . l:fg : ' guifg=#888888')
  if has('signs')
    call sign_define('cartoFlowPlus', {'text': '+', 'texthl': 'cartoFlowAddSign'})
    call sign_define('cartoFlowMinus', {'text': '-', 'texthl': 'cartoFlowDelSign'})
    call sign_define('cartoFlowChange', {'text': '~', 'texthl': 'cartoFlowAddSign'})
  endif
  if has('textprop')
    if empty(prop_type_get('cartoFlowAddLine'))
      call prop_type_add('cartoFlowAddLine', {'highlight': 'cartoFlowAddLine', 'combine': v:true})
    endif
    if empty(prop_type_get('cartoFlowDelText'))
      call prop_type_add('cartoFlowDelText', {'highlight': 'cartoFlowDelText'})
    endif
  endif
endfunction

function! s:groups(stops) abort
  let l:groups = []
  for l:stop in a:stops
    let l:path = s:resolve_path(get(l:stop, 'stop/path', ''))
    if empty(l:path)
      continue
    endif
    let l:at = index(map(copy(l:groups), 'v:val.path'), l:path)
    if l:at < 0
      call add(l:groups, {'path': l:path, 'stops': [l:stop]})
    else
      call add(l:groups[l:at].stops, l:stop)
    endif
  endfor
  return l:groups
endfunction

function! s:decorate(stops) abort
  call carto_flow#highlights()
  let l:buf = bufnr('%')
  let s:stop_decorations[l:buf] = {'matches': []}
  if has('signs')
    setlocal signcolumn=yes
  endif
  for l:stop in a:stops
    for l:range in get(l:stop, 'stop/added', [])
      let l:start = get(l:range, 'start', 0)
      let l:count = get(l:range, 'count', 0)
      if l:start > 0 && l:count > 0
        if l:start > line('$')
          continue
        endif
        for l:i in range(l:start, min([line('$'), l:start + l:count - 1]))
          if has('textprop')
            call prop_add(l:i, 1, {'type': 'cartoFlowAddLine', 'length': max([1, strlen(getline(l:i))])})
          else
            call add(s:stop_decorations[l:buf].matches, [win_getid(), matchaddpos('cartoFlowAddLine', [[l:i]], 10)])
          endif
          if has('signs')
            let s:sign_id += 1
            call sign_place(s:sign_id, 'cartoflow', 'cartoFlowPlus', l:buf, {'lnum': l:i})
          endif
        endfor
      endif
    endfor
    for l:block in get(l:stop, 'stop/removed', [])
      let l:above = get(l:block, 'above', 0)
      let l:lines = get(l:block, 'lines', [])
      if l:above > 0 && !empty(l:lines)
        if has('signs')
          let l:changed = !empty(filter(copy(get(l:stop, 'stop/added', [])), 'get(v:val, "start", 0) == l:above'))
          let s:sign_id += 1
          call sign_place(s:sign_id, 'cartoflow', l:changed ? 'cartoFlowChange' : 'cartoFlowMinus', l:buf, {'lnum': min([l:above, line('$')])})
        endif
        if has('textprop')
          let l:at = min([l:above, line('$')])
          let l:align = l:above > line('$') ? 'below' : 'above'
          for l:text in l:lines
            call prop_add(l:at, 0, {'type': 'cartoFlowDelText', 'text': '- ' . l:text, 'text_align': l:align})
          endfor
        else
          echomsg 'carto-flow: removed above ' . l:above . ': ' . join(l:lines, ' | ')
        endif
      endif
    endfor
  endfor
endfunction

function! s:owned_window(n) abort
  let s:code_windows = filter(s:code_windows, 'win_id2win(v:val) > 0')
  if a:n < len(s:code_windows)
    call win_gotoid(s:code_windows[a:n])
  else
    if !empty(s:code_windows)
      call win_gotoid(s:code_windows[-1])
      silent belowright split
    else
      silent botright vertical new
    endif
    call add(s:code_windows, win_getid())
  endif
endfunction

function! s:show_groups(groups) abort
  let l:back = win_getid()
  call s:clear_stop_decorations()
  let l:max = max([1, get(g:, 'carto_flow_max_files', 3)])
  let l:visible = a:groups[s:code_page * l:max : (s:code_page + 1) * l:max - 1]
  if empty(l:visible)
    echomsg 'carto-flow: no readable stop files for this frame'
  endif
  for l:i in range(len(l:visible))
    call s:owned_window(l:i)
    execute 'silent keepjumps hide edit ' . fnameescape(l:visible[l:i].path)
    call s:decorate(l:visible[l:i].stops)
    call cursor(get(l:visible[l:i].stops[0], 'stop/focus', 1), 1)
    normal! zz
    nnoremap <buffer> <silent> ]h :<C-u>call carto_flow#next_stop()<CR>
    nnoremap <buffer> <silent> [h :<C-u>call carto_flow#previous_stop()<CR>
  endfor
  while len(s:code_windows) > len(l:visible)
    let l:win = remove(s:code_windows, -1)
    if win_id2win(l:win) > 0
      call win_execute(l:win, 'close')
    endif
  endwhile
  let l:timeline = bufwinid(bufnr(s:timeline_name))
  if l:timeline != -1
    call win_gotoid(l:timeline)
  elseif win_id2win(l:back) > 0
    call win_gotoid(l:back)
  endif
  let l:more = len(a:groups) - (s:code_page + 1) * l:max
  if l:more > 0
    echomsg printf('carto-flow: +%d more files (Tab for next page)', l:more)
  endif
endfunction

function! carto_flow#code_view(...) abort
  let l:i = a:0 ? a:1 : s:cursor
  if l:i < 0 || l:i >= len(s:frames)
    return
  endif
  let s:cursor = l:i
  let s:code_page = 0
  let s:code_view = 1
  call s:render()
  call s:show_groups(s:groups(get(s:frames[l:i], 'stops', [])))
endfunction

function! carto_flow#code_view_at_line(lnum) abort
  let l:i = a:lnum - s:header_size - 1
  call carto_flow#code_view(l:i >= 0 && l:i < len(s:frames) ? l:i : s:cursor)
endfunction

function! carto_flow#next_file_page() abort
  if s:cursor < 0 || !s:code_view
    return
  endif
  let l:groups = s:groups(get(s:frames[s:cursor], 'stops', []))
  let l:max = max([1, get(g:, 'carto_flow_max_files', 3)])
  let l:pages = (len(l:groups) + l:max - 1) / l:max
  if l:pages > 0
    let s:code_page = (s:code_page + 1) % l:pages
    call s:show_groups(l:groups)
  endif
endfunction

" Render a single Stop: open the file, center on focus line, apply decorations.
function! carto_flow#show_stop(stop) abort
  if type(a:stop) != v:t_dict
    return
  endif
  
  let l:back = win_getid()
  call s:clear_stop_decorations()
  if s:code_view
    let l:groups = s:groups(get(s:frames[s:cursor], 'stops', []))
    let l:at = index(map(copy(l:groups), 'v:val.path'), s:resolve_path(get(a:stop, 'stop/path', '')))
    if l:at >= 0
      let l:max = max([1, get(g:, 'carto_flow_max_files', 3)])
      let s:code_page = l:at / l:max
      call s:show_groups(l:groups)
      call win_execute(s:code_windows[l:at % l:max], 'call cursor(' . get(a:stop, 'stop/focus', 1) . ', 1) | normal! zz')
    endif
    return
  endif

  let l:path = s:resolve_path(get(a:stop, 'stop/path', ''))
  let l:focus = get(a:stop, 'stop/focus', 1)
  let l:forms = get(a:stop, 'stop/forms', [])
  let l:of = get(a:stop, 'stop/of', [0, 0])
  
  if empty(l:path) || !filereadable(l:path)
    echohl WarningMsg
    echomsg 'carto-flow: stop file not readable: ' . l:path
    echohl None
    return
  endif
  
  " Open the file in a code window
  call s:owned_window(0)
  execute 'silent keepjumps hide edit ' . fnameescape(l:path)
  
  " Center on focus line
  call cursor(l:focus, 1)
  normal! zz
  
  " Keep walking available in the code window as well as in the panel.
  nnoremap <buffer> <silent> ]h :<C-u>call carto_flow#next_stop()<CR>
  nnoremap <buffer> <silent> [h :<C-u>call carto_flow#previous_stop()<CR>
  call s:decorate([a:stop])
  
  " Show stop info in status/command line
  let l:timeline = bufwinid(bufnr(s:timeline_name))
  if l:timeline != -1
    call win_gotoid(l:timeline)
  elseif win_id2win(l:back) > 0
    call win_gotoid(l:back)
  endif
  echomsg printf('%s  hunk %d/%d  [%s]', l:path, l:of[0], l:of[1], join(l:forms, ', '))
endfunction

" Navigate to next stop in the walk.
function! carto_flow#next_stop() abort
  if empty(s:stops) || (s:cursor >= 0 && empty(get(s:frame_stops, s:frames[s:cursor].index, [])))
    call s:move(v:count1)
    return
  endif
  let l:next = s:stop_cursor + v:count1
  if l:next >= len(s:stops)
    let l:next = len(s:stops) - 1
    echomsg 'carto-flow: at last stop'
  endif
  let s:stop_cursor = l:next
  let s:stop_mode = 1
  call carto_flow#seek({'index': s:stops[s:stop_cursor]['stop/frame']})
  call carto_flow#show_stop(s:stops[s:stop_cursor])
endfunction

" Navigate to previous stop in the walk.
function! carto_flow#previous_stop() abort
  if empty(s:stops) || (s:cursor >= 0 && empty(get(s:frame_stops, s:frames[s:cursor].index, [])))
    call s:move(-v:count1)
    return
  endif
  if s:stop_cursor < 0
    let s:stop_cursor = len(s:stops)
  endif
  let l:prev = s:stop_cursor - v:count1
  if l:prev < 0
    let l:prev = 0
    echomsg 'carto-flow: at first stop'
  endif
  let s:stop_cursor = l:prev
  let s:stop_mode = 1
  call carto_flow#seek({'index': s:stops[s:stop_cursor]['stop/frame']})
  call carto_flow#show_stop(s:stops[s:stop_cursor])
endfunction

" Exit diff walk stop mode: clear state and decorations.
function! carto_flow#exit_stop_mode() abort
  call s:clear_stop_decorations()
  let s:stop_mode = 0
  let s:code_view = 0
  let s:stop_cursor = -1
  echomsg 'carto-flow: exited stop mode'
endfunction

" Return current stop mode status.
function! carto_flow#stop_status() abort
  return {
        \ 'mode': s:stop_mode,
        \ 'stops': len(s:stops),
        \ 'cursor': s:stop_cursor,
        \ }
endfunction

function! carto_flow#clear() abort
  call carto_flow#exit_stop_mode()
  let s:frame_stops = {}
  let s:stops = []
  let s:frames = []
  let s:cursor = -1
  let s:follow = 1
  call s:render()
endfunction

" -------------------------------------------------------------------- layout
"
" A layout names the screen edge the carto-flow panel docks on and the share
" of the screen it takes: 'left-1/3' is a full-height column a third of the
" screen wide, 'bottom-1/2' a full-width row half the screen tall. The timeline
" and the frame detail share that panel, stacked in a column and side by side
" in a row, so the code keeps the rest of the screen. 'classic' is the old
" placement: g:carto_flow_position for the timeline, the detail split below.

function! s:layouts() abort
  return get(g:, 'carto_flow_layouts', ['left-1/3', 'left-1/2', 'bottom-1/3', 'bottom-1/2'])
endfunction

function! carto_flow#current_layout() abort
  if exists('g:carto_flow_layout')
    return g:carto_flow_layout
  endif
  return exists('g:carto_flow_position') ? 'classic' : 'left-1/3'
endfunction

" {'edge': 'left'|'right'|'top'|'bottom', 'ratio': 0 < r < 1} for NAME,
" {'edge': 'classic'} for 'classic', {} for anything else.
function! carto_flow#parse_layout(name) abort
  if type(a:name) != v:t_string
    return {}
  endif
  if a:name ==# 'classic'
    return {'edge': 'classic'}
  endif
  let l:m = matchlist(a:name, '^\(left\|right\|top\|bottom\)-\(\d\+\)/\(\d\+\)$')
  if empty(l:m)
    return {}
  endif
  let [l:n, l:d] = [str2nr(l:m[2]), str2nr(l:m[3])]
  if l:n <= 0 || l:n >= l:d
    return {}
  endif
  return {'edge': l:m[1], 'ratio': 1.0 * l:n / l:d}
endfunction

function! s:spec() abort
  let l:spec = carto_flow#parse_layout(carto_flow#current_layout())
  return empty(l:spec) ? carto_flow#parse_layout('left-1/3') : l:spec
endfunction

function! s:side(spec) abort
  return index(['left', 'right'], a:spec.edge) >= 0
endfunction

" Open the timeline window on the layout's edge, on BUF or on a new buffer
" when BUF is -1. Leaves focus in it.
function! s:open_timeline_window(buf) abort
  let l:spec = s:spec()
  let l:mods = get({'left': 'topleft vertical', 'right': 'botright vertical',
        \ 'top': 'topleft', 'bottom': 'botright'}, l:spec.edge,
        \ get(g:, 'carto_flow_position', 'topleft'))
  execute 'silent ' . l:mods . (a:buf == -1 ? ' new' : ' sbuffer ' . a:buf)
endfunction

" Open the detail window inside the panel, next to the timeline when it is
" shown, on BUF or on a new buffer when BUF is -1. Leaves focus in it.
function! s:open_detail_window(buf) abort
  let l:spec = s:spec()
  let l:timeline = bufwinid(bufnr(s:timeline_name))
  let l:mods = 'belowright'
  if l:spec.edge !=# 'classic' && l:timeline != -1
    call win_gotoid(l:timeline)
    let l:mods = s:side(l:spec) ? 'belowright' : 'belowright vertical'
  endif
  execute 'silent ' . l:mods . (a:buf == -1 ? ' new' : ' sbuffer ' . a:buf)
endfunction

" Give the panel its share of the screen and split it between timeline and
" detail (g:carto_flow_timeline_share of the panel, default 2/5, to the
" timeline). The panel windows keep their size when the code window splits.
function! s:size_panel() abort
  let l:spec = s:spec()
  if l:spec.edge ==# 'classic'
    return
  endif
  let l:wins = filter([bufwinid(bufnr(s:timeline_name)), bufwinid(bufnr(s:detail_name))],
        \ 'v:val != -1')
  if empty(l:wins) || len(l:wins) == winnr('$')
    return
  endif
  let l:share = get(g:, 'carto_flow_timeline_share', 0.4)
  if s:side(l:spec)
    let l:size = max([20, float2nr(round(&columns * l:spec.ratio))])
    for l:win in l:wins
      call setwinvar(l:win, '&winfixwidth', 0)
      call win_execute(l:win, 'vertical resize ' . l:size)
      call setwinvar(l:win, '&winfixwidth', 1)
    endfor
    if len(l:wins) == 2
      let l:total = winheight(l:wins[0]) + winheight(l:wins[1]) + 1
      call win_execute(l:wins[0], 'resize ' . max([5, float2nr(round(l:total * l:share))]))
    endif
  else
    let l:size = max([6, float2nr(round((&lines - &cmdheight) * l:spec.ratio))])
    for l:win in l:wins
      call setwinvar(l:win, '&winfixheight', 0)
      call win_execute(l:win, 'resize ' . l:size)
      call setwinvar(l:win, '&winfixheight', 1)
    endfor
    if len(l:wins) == 2
      let l:total = winwidth(l:wins[0]) + winwidth(l:wins[1]) + 1
      call win_execute(l:wins[0], 'vertical resize ' . max([30, float2nr(round(l:total * l:share))]))
    endif
  endif
endfunction

" Re-dock a shown panel under the current layout: close its windows, open
" them again on the new edge, size them, and give focus back.
function! s:apply_layout() abort
  let l:tbuf = bufnr(s:timeline_name)
  let l:dbuf = bufnr(s:detail_name)
  let l:twin = l:tbuf == -1 ? -1 : bufwinid(l:tbuf)
  let l:dwin = l:dbuf == -1 ? -1 : bufwinid(l:dbuf)
  if l:twin == -1 && l:dwin == -1
    return
  endif
  let l:back = win_getid()
  let l:focus = l:back == l:twin ? 'timeline' : l:back == l:dwin ? 'detail' : 'code'
  if !s:code_window()
    " Closing the panel must not close the last window.
    execute 'silent ' . get(g:, 'carto_flow_code_position', 'botright') . ' new'
  endif
  let l:code = s:code_window()
  for l:buf in [l:tbuf, l:dbuf]
    for l:win in (l:buf == -1 ? [] : win_findbuf(l:buf))
      call win_gotoid(l:win)
      close
    endfor
  endfor
  call win_gotoid(l:code)
  if l:twin != -1
    call s:open_timeline_window(l:tbuf)
    call s:render()
  endif
  if l:dwin != -1
    call s:open_detail_window(l:dbuf)
  endif
  call s:size_panel()
  if l:focus ==# 'timeline'
    call win_gotoid(bufwinid(l:tbuf))
  elseif l:focus ==# 'detail'
    call win_gotoid(bufwinid(l:dbuf))
  elseif win_id2win(l:back) > 0
    call win_gotoid(l:back)
  else
    call win_gotoid(l:code)
  endif
endfunction

" :CartoFlowLayout [name] -- switch to layout NAME, or with no argument to the
" next one in g:carto_flow_layouts; a negative count steps back. A shown panel
" re-docks at once, a hidden one opens there next time. Returns the layout in
" force afterwards; an unknown name changes nothing.
function! carto_flow#layout(...) abort
  let l:arg = a:0 && type(a:1) == v:t_string ? trim(a:1) : ''
  let l:step = a:0 && type(a:1) == v:t_number ? a:1 : 1
  if !empty(l:arg)
    if empty(carto_flow#parse_layout(l:arg))
      echohl ErrorMsg
      echomsg 'carto-flow: unknown layout ' . l:arg
            \ . ' (want classic or left|right|top|bottom-N/D, e.g. left-1/3)'
      echohl None
      return carto_flow#current_layout()
    endif
    let g:carto_flow_layout = l:arg
  else
    let l:all = s:layouts()
    let l:at = index(l:all, carto_flow#current_layout())
    let l:at = l:at < 0 ? (l:step > 0 ? -1 : 0) : l:at
    let g:carto_flow_layout = l:all[(l:at + l:step) % len(l:all)]
  endif
  call s:apply_layout()
  echomsg 'carto-flow: layout ' . g:carto_flow_layout
  return g:carto_flow_layout
endfunction

function! carto_flow#layout_complete(arglead, cmdline, cursorpos) abort
  let l:names = s:layouts() + ['classic']
  return filter(uniq(l:names), 'stridx(v:val, a:arglead) == 0')
endfunction

" Re-fit the panel to the screen, for after a terminal resize.
function! carto_flow#refit() abort
  call s:size_panel()
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
  nnoremap <buffer> <silent> n :<C-u>call carto_flow#next_stop()<CR>
  nnoremap <buffer> <silent> p :<C-u>call carto_flow#previous_stop()<CR>
  nnoremap <buffer> <silent> G :<C-u>call carto_flow#latest()<CR>
  nnoremap <buffer> <silent> <CR> :<C-u>call carto_flow#code_view_at_line(line('.'))<CR>
  nnoremap <buffer> <silent> d :<C-u>call carto_flow#detail_at_line(line('.'))<CR>
  nnoremap <buffer> <silent> <Tab> :<C-u>call carto_flow#next_file_page()<CR>
  nnoremap <buffer> <silent> o :<C-u>call carto_flow#open_code_at_line(line('.'))<CR>
  nnoremap <buffer> <silent> q :<C-u>call carto_flow#exit_stop_mode()<Bar>call carto_flow#close()<CR>
  nnoremap <buffer> <silent> v :<C-u>call carto_flow#layout(v:count1)<CR>
  nnoremap <buffer> <silent> V :<C-u>call carto_flow#layout(-v:count1)<CR>
  nnoremap <buffer> <silent> = :<C-u>call carto_flow#refit()<CR>
endfunction

" The detail buffer pages frames with the timeline's keys; moving re-renders
" the open detail in place (s:refresh_detail), so focus stays here.
function! s:setup_detail() abort
  setlocal buftype=nofile bufhidden=hide noswapfile nobuflisted nowrap
  nnoremap <buffer> <silent> ]f :<C-u>call carto_flow#next()<CR>
  nnoremap <buffer> <silent> [f :<C-u>call carto_flow#previous()<CR>
  nnoremap <buffer> <silent> n :<C-u>call carto_flow#next_stop()<CR>
  nnoremap <buffer> <silent> p :<C-u>call carto_flow#previous_stop()<CR>
  nnoremap <buffer> <silent> G :<C-u>call carto_flow#latest()<CR>
  nnoremap <buffer> <silent> <CR> :<C-u>call carto_flow#code_view()<CR>
  nnoremap <buffer> <silent> d :<C-u>call carto_flow#detail()<CR>
  nnoremap <buffer> <silent> o :<C-u>call carto_flow#open_code()<CR>
  nnoremap <buffer> <silent> q :<C-u>close<CR>
  nnoremap <buffer> <silent> v :<C-u>call carto_flow#layout(v:count1)<CR>
  nnoremap <buffer> <silent> V :<C-u>call carto_flow#layout(-v:count1)<CR>
  nnoremap <buffer> <silent> = :<C-u>call carto_flow#refit()<CR>
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
    call s:open_timeline_window(l:buf)
    if bufwinid(bufnr(s:detail_name)) != -1
      " A detail outlived its timeline: dock both again, focus on the timeline.
      call s:apply_layout()
      call win_gotoid(bufwinid(l:buf))
    else
      call s:size_panel()
    endif
  else
    call s:open_timeline_window(-1)
    execute 'silent file ' . fnameescape(s:timeline_name)
    call s:setup_timeline()
    call s:size_panel()
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
    call s:open_detail_window(l:buf)
  else
    call s:open_detail_window(-1)
    execute 'silent file ' . fnameescape(s:detail_name)
  endif
  call s:setup_detail()
  setlocal modifiable
  silent %delete _
  call setline(1, l:lines)
  setlocal nomodifiable
  setlocal filetype=diff
  if l:win == -1
    let l:here = win_getid()
    call s:size_panel()
    call win_gotoid(l:here)
  endif
endfunction

" ---------------------------------------------------------------- toggling

" Show or hide the panel: hiding closes the timeline and the detail beside it.
" The buffers and their frames outlive a hidden window, so the next toggle shows the same timeline rather than an empty one.
" Returns 1 when the timeline is visible afterwards.
function! carto_flow#toggle(...) abort
  let l:win = bufwinid(bufnr(s:timeline_name))
  if l:win == -1
    call call('carto_flow#open', a:000)
    return 1
  endif
  let l:back = win_getid()
  let l:detail = bufnr(s:detail_name)
  for l:id in win_findbuf(bufnr(s:timeline_name))
        \ + (l:detail == -1 ? [] : win_findbuf(l:detail))
    call win_gotoid(l:id)
    call carto_flow#close()
  endfor
  if win_id2win(l:back) > 0
    call win_gotoid(l:back)
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

" The features this script can serve, each listed only while every function it
" entitles hive to call is defined, so the list cannot outlive the functions.
" hive evals this at handshake unless g:carto_flow_features overrides it.
function! carto_flow#features() abort
  let l:table = [['carto-flow/timeline', ['carto_flow#ingest', 'carto_flow#hello']],
        \ ['carto-flow/seek', ['carto_flow#seek']],
        \ ['carto-flow/diff-walk', ['carto_flow#show_stop']]]
  let l:out = []
  for [l:feature, l:fns] in l:table
    if empty(filter(copy(l:fns), '!exists("*" . v:val)'))
      call add(l:out, l:feature)
    endif
  endfor
  return l:out
endfunction

" --------------------------------------------------------------- hot reload

" A reload leaves the previous script's reconnect timer calling its own, now
" stale, code. Stop every carto-flow reconnect timer and start this script's,
" then repaint with the code just loaded.
for s:info in timer_info()
  if string(s:info.callback) =~# '_reconnect_tick'''
    call timer_stop(s:info.id)
  endif
endfor
unlet! s:info
let s:timer = -1
call s:schedule_reconnect()
call carto_flow#highlights()
augroup carto_flow_colors
  autocmd!
  autocmd ColorScheme * call carto_flow#highlights()
augroup END
call s:render()

let &cpo = s:save_cpo
unlet s:save_cpo
