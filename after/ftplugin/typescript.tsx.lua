require("lsp.manager").setup "tsserver"
require("lsp.manager").setup "eslint"

vim.cmd [[setlocal textwidth=100]]
vim.cmd [[setlocal commentstring={/*%s*/}]]
