NeoBundle 'quickrun.vim'

set splitbelow

nnoremap <silent> <C-q> :QuickRun<CR>
" runner/vimproc/updatetime で出力バッファの更新間隔をミリ秒で設定できます
" " updatetime が一時的に書き換えられてしまうので注意して下さい
let g:quickrun_config = {
\   "_" : {
\       "outputter/buffer/split" : ":botright",
\       "outputter/buffer/close_on_empty" : 1,
\       "hook/time/enable" : 1,
\       "split" : '',
\       "runner" : "vimproc",
\       "runner/vimproc/updatetime" : 60,
\   },
\}

" <C-c> で実行を強制終了させる
" quickrun.vim が実行していない場合には <C-c> を呼び出す
" nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"
