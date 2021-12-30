require("user.lsp.manager").setup "jsonls"

vim.cmd [[setlocal autoindent]]
vim.cmd [[setlocal conceallevel=0]]
vim.cmd [[setlocal foldmethod=syntax]]
vim.cmd [[setlocal formatoptions=tcq2l]]

-- json 5 comment
vim.cmd [[syntax region Comment start="//" end="$" |]]
vim.cmd [[syntax region Comment start="/\*" end="\*/" |]]
vim.cmd [[setlocal commentstring=//\ %s]]
