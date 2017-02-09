" ブックマークを最初から表示
let g:NERDTreeShowBookmarks=1
"引数なしでvimを開いたらNERDTreeを起動
autocmd vimenter * if !argc() | NERDTree | endif

"他のバッファをすべて閉じた時にNERDTreeが開いていたらNERDTreeも一緒に閉じる。
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

"<C-e>でNERDTreeをオンオフ。いつでもどこでも。
nmap <silent> <C-e>      :NERDTreeToggle<CR>
vmap <silent> <C-e> <Esc>:NERDTreeToggle<CR>
omap <silent> <C-e>      :NERDTreeToggle<CR>
imap <silent> <C-e> <Esc>:NERDTreeToggle<CR>
cmap <silent> <C-e> <C-u>:NERDTreeToggle<CR>

"NERDTreeIgnore 無視するファイルを設定する。
let g:NERDTreeIgnore=['\.clean$', '\.swp$', '\.bak$', '\~$']

"NERDTreeShowHidden 隠しファイルを表示するか？
let g:NERDTreeShowHidden=1

"NERDTreeのツリーの幅(default31)
"let g:NERDTreeWinSize=40

"ブックマークや、ヘルプのショートカットをメニューに表示する。
"let g:NERDTreeMinimalUI=1

"NERDTreeを+|`などを使ってツリー表示をする。
let g:NERDTreeDirArrows=0

map  <C-l> :tabn<CR> " move to next tab
map  <C-h> :tabp<CR> " move to the previous tab
