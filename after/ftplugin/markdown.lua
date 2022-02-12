-- Custom conceal (does not work with existing syntax highlight plugin)
vim.cmd [[syntax match todoCheckbox "\v.*\[\ \]"hs=e-2 conceal cchar=]]
vim.cmd [[syntax match todoCheckbox "\v.*\[x\]"hs=e-2 conceal cchar=]]
vim.cmd [[setlocal conceallevel=2]]
vim.cmd [[setlocal spell spelllang=en,cjk]]
vim.cmd [[setlocal spelloptions=camel]]
vim.cmd [[setlocal spellcapcheck=]] --don't check for capital letters at start of sentence
vim.cmd [[set spellsuggest=best,9]] -- Show nine spell checking candidates at most

vim.cmd [[highlight Conceal guibg=NONE]]

-- https://vi.stackexchange.com/a/4003/16249
vim.cmd [[syntax match NoSpellAcronym '\<\(\u\|\d\)\{3,}s\?\>' contains=@NoSpell]]

vim.cmd [[iabbrev :tup: 👍]]
vim.cmd [[iabbrev :tdo: 👎]]
vim.cmd [[iabbrev :smi: 😊]]
vim.cmd [[iabbrev :sad: 😔]]
