NeoBundle 'Shougo/vimshell'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/neocomplcache'

let g:vimshell_prompt_expr = 'getcwd()." > "'
let g:vimshell_prompt_pattern = '^\f\+ > '

" vimshell setting
let g:vimshell_interactive_update_time = 10
let g:vimshell_prompt = $USERNAME."% "

" vimshell map
" nnoremap <silent> vs :VimShell<CR>
" nnoremap <silent> vsc :VimShellCreate<CR>
nnoremap <silent> vs :VimShellPop<CR>

" Initialize execute file list.
let g:VimShell_ExecuteFileList = {}
let g:VimShell_ExecuteFileList['txt'] = 'vim'
let g:VimShell_ExecuteFileList['vim'] = 'vim'
let g:VimShell_ExecuteFileList['rb'] = 'ruby'
let g:VimShell_ExecuteFileList['pl'] = 'perl'
let g:VimShell_ExecuteFileList['py'] = 'python'

let g:VimShell_EnableInteractive = 1
