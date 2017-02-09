NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimfiler'

autocmd VimEnter * VimFiler -split -simple -winwidth=30 -no-quit
" セーフモードの設定(OFF
let g:vimfiler_safe_mode_by_default=0
" netrwは常にtree view
let g:netrw_liststyle = 3
let g:vimfiler_as_default_explorer = 1

" nnoremap <C-e> :VimFiler -split -simple -winwidth=30 -toggle -no-quit<Cr>
" netrwは常にtree view
let g:netrw_liststyle = 3
" 'v'でファイルを開くときは右側に開く。(デフォルトが左側なので入れ替え)
let g:netrw_altv = 1
" 'o'でファイルを開くときは下側に開く。(デフォルトが上側なので入れ替え)
let g:netrw_alto = 1
" 'v'や'o'で開かれる新しいウィンドウのサイズを指定する
let g:netrw_winsize = 80
