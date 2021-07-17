setlocal synmaxcol=0
setlocal nofoldenable
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4
setlocal conceallevel=0
setlocal spell spelllang=en_gb
setlocal nonumber norelativenumber

onoremap <buffer>ih :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_"<cr>
onoremap <buffer>ah :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rg_vk0"<cr>
onoremap <buffer>aa :<c-u>execute "normal! ?^--\\+$\r:nohlsearch\rg_vk0"<cr>
onoremap <buffer>ia :<c-u>execute "normal! ?^--\\+$\r:nohlsearch\rkvg_"<cr>

if v:lua.plugin_loaded("markdown-preview.nvim")
  nmap <buffer> <localleader>Om <Plug>MarkdownPreviewToggle
endif
