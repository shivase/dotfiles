"---------------------------------------
" vim settings
"---------------------------------------
set nocompatible      " No vim compatibility
set number            " 行数を表示
set expandtab
set tw=0
set tabstop=2
set shiftwidth=2
set softtabstop=2
set list
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%   " 見えない文字を可視化
set clipboard+=unnamed
set ambiwidth=double
let mapleader = ","              " key map leader <Leader>
set scrolloff=5                  " スクロール時の余白確保
set nowrap                       " 自動折り返し不可
set textwidth=0                  " 一行に長い文章を書いていても自動折り返しをしない
set nobackup                     " バックアップ取らない
set autoread                     " 他で書き換えられたら自動で読み直す
set noswapfile                   " スワップファイル作らない
set hidden                       " 編集中でも他のファイルを開けるようにする
set backspace=indent,eol,start   " バックスペースでなんでも消せるように
set formatoptions=lmoq           " テキスト整形オプション，マルチバイト系を追加
set vb t_vb=                     " ビープをならさない
set browsedir=buffer             " Exploreの初期ディレクトリ
set showcmd                      " コマンドをステータス行に表示
set showmode                     " 現在のモードを表示
set viminfo='50,<1000,s100,\"50  " viminfoファイルの設定
set modelines=0                  " モードラインは無効
set notitle                      " vimを使ってくれてありがとう
set hlsearch                     " 検索文字ハイライト
set cursorline                   " カーソルラインをハイライト
filetype plugin on               " ファイルタイプ判定をon
syntax enable

"---------------------------------------
" vim ショートカット上書き設定
"---------------------------------------

"" 挿入モードでCtrl+kを押すとクリップボードの内容を貼り付けられるようにする "
imap <C-p>  <ESC>"*pa

" Ev/Rvでvimrcの編集と反映
" command! Ev edit $MYVIMRC
" command! Rv source $MYVIMRC

"----------------------------------------------------------
" plugin
"----------------------------------------------------------

call plug#begin('~/.vim/plugged')

Plug 'Shougo/vimproc.vim', { 'dir': '~/.vim/plugged/vimproc.vim', 'do': 'make' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

"----------------------------------------------------------
" 言語系設定
" ---------------------------------------------------------
" 末尾の全角と半角の空白文字を赤くハイライト
Plug 'bronson/vim-trailing-whitespace'

" インデントの可視化
Plug 'Yggdroot/indentLine'

" block chain program
Plug 'tomlion/vim-solidity'

" endやfiなどを自動的に補完する
Plug 'tpope/vim-endwise'

" ruby programming
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
Plug 'todesking/ruby_hl_lvar.vim', { 'for': 'ruby' }

" ツリー表示
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'jistr/vim-nerdtree-tabs'
Plug 'Xuyuanp/nerdtree-git-plugin' "ファイル変更を通知
Plug 'airblade/vim-gitgutter'      "ファイル変更時に差分表示

" yank highlight
Plug 'machakann/vim-highlightedyank'

" indent highlight
Plug 'nathanaelkane/vim-indent-guides'

" auto formatter
Plug 'Chiel92/vim-autoformat'

"----------------------------------------------------------
" NERDTree の設定
" ---------------------------------------------------------
" ディレクトリ表示の設定
let g:NERDTreeDirArrows = 1
let g:NERDTreeDirArrowExpandable  = '→'
let g:NERDTreeDirArrowCollapsible = '↓'
" ctrl-n で NERDTree を起動
nnoremap <silent> <C-e> :NERDTreeToggle<CR>

"----------------------------------------------------------
" ステータスラインの設定
"----------------------------------------------------------
Plug 'itchyny/lightline.vim'
set laststatus=2 " ステータスラインを常に表示
set showmode     " 現在のモードを表示
set showcmd      " 打ったコマンドをステータスラインの下に表示
set ruler        " ステータスラインの右側にカーソルの現在位置を表示する

Plug 'vim-airline/vim-airline'
" Powerline系フォントを利用する
let g:airline_powerline_fonts = 1
"
" タブバーのカスタマイズを有効にする
let g:airline#extensions#tabline#enabled = 1
"
" タブバーの右領域を非表示にする
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_tab_type = 0
let g:airline#extensions#tabline#show_close_button = 0

Plug 'tpope/vim-fugitive'
" ブランチ情報を表示する
let g:airline#extensions#branch#enabled = 1

" 構文エラーチェック
"----------------------------------------------------------
Plug 'scrooloose/syntastic'
"" 構文エラー行に「>>」を表示
let g:syntastic_enable_signs = 1
" 他のVimプラグインと競合するのを防ぐ
let g:syntastic_always_populate_loc_list = 1
" 構文エラーリストを非表示
let g:syntastic_auto_loc_list = 0
" ファイルを開いた時に構文エラーチェックを実行しない
let g:syntastic_check_on_open = 0
" for ruby checker
let g:syntastic_ruby_checkers = ['rubocop']
let g:syntastic_mode_map = { 'mode': 'passive',
                           \ 'active_filetypes': ['javascript','ruby'],
                           \ 'passive_filetypes': [] }
" 「:wq」で終了する時も構文エラーチェックする
let g:syntastic_check_on_wq = 1

" coffee script
"----------------------------------------------------------
Plug 'kchmck/vim-coffee-script', { 'for' : 'coffee' }

" teffaform
"----------------------------------------------------------
Plug 'hashivim/vim-terraform'
let g:terraform_fmt_on_save = 1

" Go Language
"----------------------------------------------------------
Plug 'fatih/vim-go'

" JavaScript Language
"----------------------------------------------------------
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue'] }


" SQLLanguage
"----------------------------------------------------------
" :SQLUFormatter
Plug 'vim-scripts/Align'
Plug 'vim-scripts/SQLUtilities'

let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.json,*.css,*.scss,*.less,*.graphql PrettierAsync

call plug#end()



