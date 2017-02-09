NeoBundle 'h1mesuke/vim-alignta.git'

let g:Align_xstrlen=3

" for alingta
vnoremap <silent> => :Alignta @1 =><CR>
vnoremap <silent> = :Alignta @1 =<CR>
vnoremap <silent> == =
