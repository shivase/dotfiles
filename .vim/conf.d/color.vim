NeoBundle 'Shougo/unite.vim'
NeoBundle 'ujihisa/unite-colorscheme'
NeoBundle 'rhysd/vim-color-splatoon'
" ログファイルを色づけしてくれる
NeoBundle 'vim-scripts/AnsiEsc.vim'

" solarized
NeoBundle 'altercation/vim-colors-solarized'
" mustang
NeoBundle 'croaker/mustang-vim'
" jellybeans
NeoBundle 'nanotech/jellybeans.vim'
" molokai
NeoBundle 'tomasr/molokai'
"DuoTone
NeoBundle 'simurai/duotone-dark-syntax'

" To Preview color scheme
" :Unite colorscheme -auto-preview

colorscheme slate
if &term =~ "xterm-256color" || "screen-256color"
  set t_Co=256
  set t_Sf=[3%dm
  set t_Sb=[4%dm
elseif &term =~ "xterm-color"
  set t_Co=8
  set t_Sf=[3%dm
  set t_Sb=[4%dm
endif

"This is for solarized settings
"colorscheme solarized
"set background=dark
"let g:solarized_termcolors=256

syntax enable
hi PmenuSel cterm=reverse ctermfg=33 ctermbg=222 gui=reverse guifg=#3399ff guibg=#f0e68c
