let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0
let g:prettier#config#single_quote = 'true'
let g:prettier#config#trailing_comma = 'all'
let g:prettier#quickfix_enabled = 0
let g:prettier#quickfix_auto_focus = 0
" let g:prettier#config#parser = ''
" let g:prettier#exec_cmd_async = 1
" let g:prettier#config#print_width = 'auto'
" let g:prettier#partial_format=1

" when running at every change you may want to disable quickfix
" autocmd TextChanged,InsertLeave *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync

nmap <Leader>vy <Plug>(Prettier)
nmap <Leader>vy :Prettier<CR>



