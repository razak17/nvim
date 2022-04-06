setlocal spell spelllang=en,cjk
setlocal spelloptions=camel
setlocal spellcapcheck= " don't check for capital letters at start of sentence
set spellsuggest=best,9 " Show nine spell checking candidates at most

" no distractions in markdown files
setlocal nonumber norelativenumber

iabbrev :tup: 👍
iabbrev :tdo: 👎
iabbrev :smi: 😊
iabbrev :sad: 😔

onoremap <buffer>ih :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_"<cr>
onoremap <buffer>ah :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rg_vk0"<cr>
onoremap <buffer>aa :<c-u>execute "normal! ?^--\\+$\r:nohlsearch\rg_vk0"<cr>
onoremap <buffer>ia :<c-u>execute "normal! ?^--\\+$\r:nohlsearch\rkvg_"<cr>

if v:lua.rvim.plugin_loaded("markdown-preview.nvim")
  nmap <buffer> <localleader>P <Plug>MarkdownPreviewToggle
endif
