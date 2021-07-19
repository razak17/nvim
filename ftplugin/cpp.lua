require'lsp.clang'.format()
require'lsp.clang'.lint()
require'lsp.clang'.init()

core.nnoremap('<F10>', ':call v:lua.RunCPP()<CR>')
