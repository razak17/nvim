setlocal shiftwidth=2
setlocal softtabstop=2
setlocal tabstop=2

nnoremap <F10> :!gcc % -o %< && ./%< <CR>

