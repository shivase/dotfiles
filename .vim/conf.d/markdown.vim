NeoBundle 'kannokanno/previm'
NeoBundle 'tyru/open-browser.vim'

let g:previm_disable_default_css = 1
let g:previm_custom_css_path = '~/.pandoc/github.css'

nnoremap <silent> <F7> :PrevimOpen<CR>
