-- Set indent width to two spaces
vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
-- Fix quirkiness in indentation
vim.opt_local.indentkeys:remove('*<Return>')
-- setlocal indentkeys-=*<Return>
-- Make lines longer, and don't break them automatically
vim.cmd([[setlocal tw=120 linebreak textwidth=0]])
vim.wo.wrap = false
vim.opt_local.matchpairs:append('<:>')
