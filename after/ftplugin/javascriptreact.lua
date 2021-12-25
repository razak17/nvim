require("lsp.manager").setup "tsserver"
require("lsp.manager").setup "eslint"

vim.cmd [[setlocal commentstring={/*%s*/}]]
