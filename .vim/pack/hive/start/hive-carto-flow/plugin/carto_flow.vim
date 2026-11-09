" carto_flow.vim -- Carto Flow timeline presenter for hive.carto-flow.vim
"
" Commands:
"   :CartoFlow [port|host:port]         open the timeline buffer and connect
"   :CartoFlowConnect [port|host:port]  connect without opening the buffer
"   :CartoFlowDisconnect                 close the channel, stop reconnecting
"   :CartoFlowClear                      forget the frames shown in this Vim
"   :CartoFlowCode                       open the code of the frame under the cursor
"   :CartoFlowFollow [on|off]            follow live edits into the code, or flip it
"   :CartoFlowToggle                    show or hide the timeline window
"   :CartoFlowLayout [name]              dock the panel by layout name, or cycle
"                                        (left-1/3, left-1/2, bottom-1/3, bottom-1/2, classic)
"
" Keys, in the timeline and in the carto-flow://frame detail:
"   n ]f  next frame     p [f  previous frame     G  latest, then follow
"   o     open the frame's code at its first changed line
"   <CR>  (timeline) open the detail     q  close the window
"   v  next layout     V  previous layout     =  re-fit the panel to the screen
"
" Global keys (<leader> is your mapleader; every one is skipped when the key is
" already taken, and the whole set is refused by
" g:carto_flow_no_default_maps = 1):
"   <leader>cf  <F9>    show or hide the timeline
"   <leader>cl          open it on the newest frame and follow
"   <leader>ce  <S-F9>  follow live edits into the code, or stop
"   <leader>cd          disconnect, or connect again
"   <leader>cv          next layout
" Bind your own with <Plug>(carto-flow-toggle), -latest, -follow, -connect, -layout.
"
" g:carto_flow_autoconnect = 1 connects on VimEnter without :CartoFlow. When
" hive.carto-flow.vim is mounted with a runtime provisioner, a loader it
" installs next to this plugin does that for you.

if exists('g:loaded_carto_flow')
  finish
endif
let g:loaded_carto_flow = 1

if !has('channel') || !has('timers')
  echohl WarningMsg
  echomsg 'carto-flow: this Vim lacks +channel or +timers'
  echohl None
  finish
endif

" What this Vim advertises to hive over the hive-vessel handshake is
" carto_flow#features(), derived from the functions the loaded autoload script
" defines; g:carto_flow_features, when set, replaces it. The server also checks
" each function a feature entitles it to call before lowering a frame to
" carto_flow#ingest or a cursor move to carto_flow#seek; a Vim without this
" plugin gets the generic hive-vessel panel instead.

command! -nargs=? CartoFlow call carto_flow#open(<f-args>)
command! -nargs=? CartoFlowConnect call carto_flow#connect(<f-args>)
command! -nargs=0 CartoFlowDisconnect call carto_flow#disconnect()
command! -nargs=0 CartoFlowClear call carto_flow#clear()
command! -nargs=0 CartoFlowCode call carto_flow#open_code()
command! -nargs=0 CartoFlowWalkStop call carto_flow#exit_stop_mode()
command! -nargs=? -complete=customlist,carto_flow#follow_complete CartoFlowFollow
      \ call carto_flow#follow_edits(<f-args>)

command! -nargs=? CartoFlowToggle call carto_flow#toggle(<f-args>)
command! -nargs=? -complete=customlist,carto_flow#layout_complete CartoFlowLayout
      \ call carto_flow#layout(<f-args>)

" Named mappings first: a vimrc binds its own key to one of these, and the
" default set below is then skipped for that action.
nnoremap <silent> <Plug>(carto-flow-toggle)  :<C-u>call carto_flow#toggle()<CR>
nnoremap <silent> <Plug>(carto-flow-latest)  :<C-u>call carto_flow#show_latest()<CR>
nnoremap <silent> <Plug>(carto-flow-follow)  :<C-u>call carto_flow#follow_edits()<CR>
nnoremap <silent> <Plug>(carto-flow-connect) :<C-u>call carto_flow#toggle_connection()<CR>
nnoremap <silent> <Plug>(carto-flow-layout)  :<C-u>call carto_flow#layout(v:count1)<CR>

" A default key is installed only when the key itself is free and nothing the
" user wrote already reaches that action: someone else's <F9> is someone
" else's <F9>.
function! s:default_map(lhs, plug, claimed) abort
  if a:claimed || !empty(maparg(a:lhs, 'n'))
    return 0
  endif
  execute 'nmap <silent> ' . a:lhs . ' ' . a:plug
  return 1
endfunction

if !get(g:, 'carto_flow_no_default_maps', 0)
  " The leader is read here rather than written as <leader>, so the guard
  " above asks maparg() about the key the user will actually press.
  let s:leader = get(g:, 'mapleader', '\')
  " Who claims an action is settled BEFORE the first default is installed, so
  " the leader key does not talk the function key out of the same action.
  let s:claimed = {}
  for s:plug in ['<Plug>(carto-flow-toggle)', '<Plug>(carto-flow-latest)',
        \ '<Plug>(carto-flow-follow)', '<Plug>(carto-flow-connect)',
        \ '<Plug>(carto-flow-layout)']
    let s:claimed[s:plug] = hasmapto(s:plug, 'n')
  endfor
  for s:pair in [[s:leader . 'cf', '<Plug>(carto-flow-toggle)'],
        \ [s:leader . 'cl', '<Plug>(carto-flow-latest)'],
        \ [s:leader . 'ce', '<Plug>(carto-flow-follow)'],
        \ [s:leader . 'cd', '<Plug>(carto-flow-connect)'],
        \ [s:leader . 'cv', '<Plug>(carto-flow-layout)'],
        \ ['<F9>', '<Plug>(carto-flow-toggle)'],
        \ ['<S-F9>', '<Plug>(carto-flow-follow)']]
    call s:default_map(s:pair[0], s:pair[1], s:claimed[s:pair[1]])
  endfor
  unlet s:leader s:claimed s:pair s:plug
endif

" The panel keeps its share of the screen when the terminal is resized.
augroup carto_flow_layout
  autocmd!
  autocmd VimResized * call carto_flow#refit()
augroup END

if get(g:, 'carto_flow_autoconnect', 0)
  if v:vim_did_enter
    call carto_flow#connect()
  else
    augroup carto_flow_autoconnect
      autocmd!
      autocmd VimEnter * ++once call carto_flow#connect()
    augroup END
  endif
endif
