" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <silent><expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<C-h>"

"map <c-p> to manually trigger completion
imap <silent> <c-space> <Plug>(completion_trigger)

" Switch completion source
imap <c-h> <Plug>(completion_next_source)
imap <c-k> <Plug>(completion_prev_source)

" non ins-complete method should be specified in 'mode' (completion-buffers)
" \{'complete_items': ['path', 'buffers', 'lsp', 'snippet']},
" let g:completion_chain_complete_list = [
    " \{'complete_items': ['lsp']},
    " \{'complete_items': ['buffers']},
    " \{'complete_items': ['path']},
    " \{'complete_items': ['snippet']},
    " \{'mode': '<c-y>'},
    " \{'mode': '<c-n>'}
" \]
