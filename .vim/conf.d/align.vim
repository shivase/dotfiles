NeoBundle 'junegunn/vim-easy-align'

" ヴィジュアルモードで選択し,easy-align 呼んで整形.(e.g. vip<Enter>)
vmap <Enter> <Plug>(EasyAlign)

" easy-align を呼んだ上で,移動したりテキストオブジェクトを指定して整形.(e.g. gaip)
nmap ga <Plug>(EasyAlign)
