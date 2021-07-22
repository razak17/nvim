require'lsp.tsserver.format'.init()
require'lsp.tsserver.lint'.init()
require'lsp.tsserver'.init()

vim.cmd [[setlocal textwidth=100]]
core.nnoremap('<F10>', ':call v:lua.RunTS()<CR>')
