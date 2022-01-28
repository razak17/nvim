require("user.lsp.manager").setup "html"
-- require("user.lsp.manager").setup "emmet_ls"

-- Set indent width to two spaces
vim.cmd [[setlocal ts=2 sw=2 sts=2]]

-- Fix quirkiness in indentation
vim.cmd [[setlocal indentkeys-=*<Return>]]

-- Make lines longer, and don't break them automatically
vim.cmd [[setlocal tw=120 linebreak textwidth=0]]
vim.cmd [[setlocal nowrap]]
vim.cmd [[setlocal matchpairs+=<:>]]
