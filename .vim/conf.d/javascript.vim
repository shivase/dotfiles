NeoBundle "pangloss/vim-javascript"
NeoBundle 'hail2u/vim-css3-syntax'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'open-browser.vim'
NeoBundle 'othree/javascript-libraries-syntax.vim'
NeoBundle 'marijnh/tern_for_vim', {
  \ 'build': {
  \   'others': 'npm install'
  \}}


"----------------------------------------
" open-browsere
"----------------------------------------
" カーソル下のURLをブラウザで開く
nmap <Leader>o <Plug>(openbrowser-open)
vmap <Leader>o <Plug>(openbrowser-open)
" ググる
nnoremap <Leader>g :<C-u>OpenBrowserSearch<Space><C-r><C-w><Enter>

"----------------------------------------
" javascript-libraries-syntax
"----------------------------------------

let g:used_javascript_libs = 'underscore,backbone,flux,react,angularjs,angularui,jquery'

