" Custom conceal (does not work with existing syntax highlight plugin)
setlocal conceallevel=2
setlocal spell spelllang=en,cjk
setlocal spelloptions=camel
setlocal spellcapcheck= " don't check for capital letters at start of sentence
set spellsuggest=best,9 " Show nine spell checking candidates at most

" no distractions in markdown files
setlocal nonumber norelativenumber

" https://vi.stackexchange.com/a/4003/16249
syntax match NoSpellAcronym '\<\(\u\|\d\)\{3,}s\?\>' contains=@NoSpell

syntax match todoCheckbox "\v.*\[\ \]"hs=e-2 conceal cchar=
syntax match todoCheckbox "\v.*\[x\]"hs=e-2 conceal cchar=

iabbrev :tup: 👍
iabbrev :tdo: 👎
iabbrev :smi: 😊
iabbrev :sad: 😔

onoremap <buffer>ih :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_"<cr>
onoremap <buffer>ah :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rg_vk0"<cr>
onoremap <buffer>aa :<c-u>execute "normal! ?^--\\+$\r:nohlsearch\rg_vk0"<cr>
onoremap <buffer>ia :<c-u>execute "normal! ?^--\\+$\r:nohlsearch\rkvg_"<cr>

if v:lua.as.plugin_loaded("markdown-preview.nvim")
  nmap <buffer> <localleader>p <Plug>MarkdownPreviewToggle
endif
