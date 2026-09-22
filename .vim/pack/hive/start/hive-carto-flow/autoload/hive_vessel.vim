" hive-vessel -- Vim side of the :vim-channel dialect.
"
" hive sends channel commands ["call", "hive_vessel#...", args]. Every function
" here paints data it is given; rendering decisions (what lines, which face)
" were already made by hive-vessel.doc/render-lines on the JVM side.
"
" SPDX-License-Identifier: MIT

let s:panels = get(s:, 'panels', {})

let g:hive_vessel_faces = get(g:, 'hive_vessel_faces', {
      \ 'title': 'Title', 'heading': 'Statement', 'muted': 'Comment',
      \ 'info': 'Identifier', 'success': 'DiffAdd', 'warn': 'WarningMsg',
      \ 'error': 'ErrorMsg', 'added': 'DiffAdd', 'removed': 'DiffDelete',
      \ 'hunk': 'DiffChange', 'code': 'Constant', 'link': 'Underlined'})

function! hive_vessel#notify(message, level) abort
  if a:level ==# 'error'
    echohl ErrorMsg
  elseif a:level ==# 'warn'
    echohl WarningMsg
  endif
  for l:line in split(a:message, "\n", 1)
    echomsg l:line
  endfor
  echohl None
  return 1
endfunction

function! s:panel_buffer(id) abort
  let l:bnr = get(s:panels, a:id, -1)
  if l:bnr == -1 || !bufexists(l:bnr)
    let l:bnr = bufadd('hive://' . a:id)
    " Options first: a loaded buffer named like a path (a panel id with a
    " slash) would otherwise be read as a file and announce [New DIRECTORY].
    call setbufvar(l:bnr, '&buftype', 'nofile')
    call setbufvar(l:bnr, '&bufhidden', 'hide')
    call setbufvar(l:bnr, '&swapfile', 0)
    silent call bufload(l:bnr)
    let s:panels[a:id] = l:bnr
  endif
  return l:bnr
endfunction

" Neovim has no text properties; extmarks in one namespace paint the same
" faces (cleared and re-set on every show_panel).
function! s:highlight_nvim(bnr, lines) abort
  let l:ns = nvim_create_namespace('hive_vessel')
  call nvim_buf_clear_namespace(a:bnr, l:ns, 0, -1)
  let l:row = 0
  for l:line in a:lines
    let l:target = get(g:hive_vessel_faces, l:line.face, '')
    if l:target !=# '' && strlen(l:line.text) > 0
      call nvim_buf_set_extmark(a:bnr, l:ns, l:row, 0,
            \ {'end_col': strlen(l:line.text), 'hl_group': l:target})
    endif
    let l:row += 1
  endfor
endfunction

function! s:highlight(bnr, lines) abort
  if has('nvim')
    call s:highlight_nvim(a:bnr, a:lines)
    return
  endif
  if !exists('*prop_add')
    return
  endif
  let l:lnum = 0
  for l:line in a:lines
    let l:lnum += 1
    let l:target = get(g:hive_vessel_faces, l:line.face, '')
    if l:target ==# '' || strlen(l:line.text) == 0
      continue
    endif
    let l:type = 'hive_vessel_' . l:line.face
    if empty(prop_type_get(l:type))
      " Own group, linked by default: a link to a group that does not exist
      " yet (syntax off) is legal, a prop type naming one is not.
      let l:group = 'HiveVessel_' . l:line.face
      execute 'highlight default link ' . l:group . ' ' . l:target
      call prop_type_add(l:type, {'highlight': l:group})
    endif
    call prop_add(l:lnum, 1, {'type': l:type, 'length': strlen(l:line.text), 'bufnr': a:bnr})
  endfor
endfunction

function! s:line_count(bnr) abort
  let l:info = getbufinfo(a:bnr)
  return empty(l:info) ? 1 : l:info[0].linecount
endfunction

" Cursor and scroll of every window showing BNR, plus whether that window was
" parked at the end: a reader at the bottom of a log follows the new end,
" everyone else keeps the line they were on.
function! s:save_views(bnr) abort
  let l:last = s:line_count(a:bnr)
  let l:views = []
  for l:win in win_findbuf(a:bnr)
    let s:scratch = {}
    call win_execute(l:win, 'let s:scratch = winsaveview()')
    let l:info = getwininfo(l:win)
    call add(l:views, {'win': l:win, 'view': copy(s:scratch),
          \ 'tail': !empty(l:info) && l:info[0].botline >= l:last})
  endfor
  return l:views
endfunction

function! s:restore_views(bnr, views) abort
  let l:last = s:line_count(a:bnr)
  let l:live = win_findbuf(a:bnr)
  for l:v in a:views
    if index(l:live, l:v.win) == -1
      continue
    endif
    if l:v.tail
      call win_execute(l:v.win, 'call cursor(' . l:last . ', 1)')
      call win_execute(l:v.win, 'normal! zb')
    else
      let s:scratch = l:v.view
      call win_execute(l:v.win, 'call winrestview(s:scratch)')
    endif
  endfor
endfunction

function! s:ensure_window(bnr) abort
  if bufwinid(a:bnr) != -1 || get(g:, 'hive_vessel_headless', 0)
    return
  endif
  execute 'botright sbuffer ' . a:bnr
  nnoremap <buffer> <silent> <CR> :call hive_vessel#visit()<CR>
  wincmd p
endfunction

" Show LINES ([{text, face, file?, line?}]) in the panel buffer for ID.
"
" A live panel is re-sent on every refresh tick, so an unchanged render must
" cost nothing: repainting would take the reader's cursor and scroll position
" twice a second. The lines painted last are the content key.
function! hive_vessel#show_panel(id, title, lines) abort
  let l:bnr = s:panel_buffer(a:id)
  let l:vars = getbufinfo(l:bnr)[0].variables
  if has_key(l:vars, 'hive_vessel_lines')
        \ && get(l:vars, 'hive_vessel_title', '') ==# a:title
        \ && l:vars.hive_vessel_lines ==# a:lines
    call s:ensure_window(l:bnr)
    return l:bnr
  endif
  let l:views = s:save_views(l:bnr)
  call setbufvar(l:bnr, '&modifiable', 1)
  silent call deletebufline(l:bnr, 1, '$')
  call setbufline(l:bnr, 1, map(copy(a:lines), 'v:val.text'))
  call setbufvar(l:bnr, 'hive_vessel_lines', a:lines)
  call setbufvar(l:bnr, 'hive_vessel_title', a:title)
  call s:highlight(l:bnr, a:lines)
  call setbufvar(l:bnr, '&modifiable', 0)
  call s:restore_views(l:bnr, l:views)
  call s:ensure_window(l:bnr)
  return l:bnr
endfunction

function! hive_vessel#visit() abort
  let l:entry = get(get(b:, 'hive_vessel_lines', []), line('.') - 1, {})
  if has_key(l:entry, 'file')
    wincmd p
    call hive_vessel#open_file(l:entry.file, get(l:entry, 'line', 1), 1)
  endif
endfunction

function! hive_vessel#close_panel(id) abort
  let l:bnr = get(s:panels, a:id, -1)
  if l:bnr != -1 && bufexists(l:bnr)
    execute 'bwipeout! ' . l:bnr
  endif
  if has_key(s:panels, a:id)
    call remove(s:panels, a:id)
  endif
  return 1
endfunction

" `hide edit`: a plain `edit` refuses (E37) while the current buffer is modified.
function! hive_vessel#open_file(file, line, column) abort
  execute 'hide edit ' . fnameescape(a:file)
  call cursor(a:line, a:column)
  return bufnr('%')
endfunction

" Exact name lookup: bufnr() treats its argument as a file pattern.
function! s:buffer_named(name) abort
  for l:info in getbufinfo()
    if l:info.name ==# a:name || fnamemodify(l:info.name, ':t') ==# a:name
      return l:info.bufnr
    endif
  endfor
  return -1
endfunction

function! hive_vessel#send_to_terminal(name, text) abort
  let l:bnr = s:buffer_named(a:name)
  if l:bnr == -1
    throw 'hive_vessel: no terminal buffer ' . a:name
  endif
  if exists('*term_sendkeys')
    call term_sendkeys(l:bnr, a:text)
  else
    call chansend(getbufvar(l:bnr, '&channel'), a:text)
  endif
  return 1
endfunction

function! hive_vessel#panel_lines(id) abort
  let l:bnr = get(s:panels, a:id, -1)
  return l:bnr == -1 ? [] : getbufline(l:bnr, 1, '$')
endfunction
