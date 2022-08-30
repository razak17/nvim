vim.bo.autoindent = true
vim.wo.conceallevel = 0
vim.bo.expandtab = true
vim.wo.foldmethod = 'syntax'
vim.bo.formatoptions = 'tcq2l'
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
-- json 5 comment
vim.cmd([[syntax region Comment start="//" end="$" |]])
vim.cmd([[syntax region Comment start="/\*" end="\*/" |]])
