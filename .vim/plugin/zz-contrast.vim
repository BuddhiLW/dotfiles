" High-contrast colors over a transparent, wallpaper-derived terminal palette.
" Loads after ~/.vimrc (plugin/ runs after vimrc, so gruvbox from Plug is on rtp).
" Delete this file to go back to the terminal palette.

if !has('termguicolors') | finish | endif

let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_italic = 1

" explicit truecolor: stop inheriting the wallpaper palette
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors
set background=dark

function! s:Contrast() abort
  hi Normal       guibg=NONE ctermbg=NONE
  hi EndOfBuffer  guibg=NONE guifg=#665c54
  hi NonText      guibg=NONE guifg=#7c6f64
  hi SignColumn   guibg=NONE
  hi FoldColumn   guibg=NONE
  hi Comment      guifg=#d5c4a1 gui=italic
  hi LineNr       guifg=#ebdbb2 guibg=NONE
  hi StatusLine   guifg=#fbf1c7 guibg=#504945 gui=bold cterm=bold
  hi StatusLineNC guifg=#d5c4a1 guibg=#3c3836 gui=NONE cterm=NONE
  hi VertSplit    guifg=#665c54 guibg=NONE gui=NONE
  hi ModeMsg      guifg=#fabd2f guibg=NONE gui=bold
  hi MoreMsg      guifg=#b8bb26 guibg=NONE
  hi Visual       guibg=#665c54 gui=NONE
  hi Pmenu        guifg=#ebdbb2 guibg=#3c3836
  hi PmenuSel     guifg=#282828 guibg=#83a598 gui=bold
  hi Search       guifg=#282828 guibg=#fabd2f gui=NONE
  hi IncSearch    guifg=#282828 guibg=#fe8019 gui=NONE
  hi MatchParen   guifg=#fabd2f guibg=#665c54 gui=bold
endfunction

augroup zz_contrast
  autocmd!
  " re-apply after any colorscheme change and after the vimrc's FileType hi overrides
  autocmd ColorScheme * call s:Contrast()
  autocmd FileType * call s:Contrast()
augroup END

if empty(globpath(&rtp, 'colors/gruvbox.vim'))
  silent! colorscheme habamax
else
  colorscheme gruvbox
endif
call s:Contrast()
