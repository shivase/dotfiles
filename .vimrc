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

"---------------------------------------
" plugin
"---------------------------------------

call plug#begin('~/.vim/plugged')

Plug 'Shougo/vimproc.vim', { 'dir': '~/.vim/plugged/vimproc.vim', 'do': 'make' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

call plug#end()
