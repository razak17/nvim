require'lsp.tsserver.format'.init()
require'lsp.tsserver.lint'.init()
require'lsp.tsserver'.init()

core.nnoremap('<F10>', ':call v:lua.RunJS()<CR>')
