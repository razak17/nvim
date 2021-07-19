require'lsp.go'.format()
require'lsp.go'.lint()
require'lsp.go'.init()

core.nnoremap('<F10>', ':call v:lua.RunGo()<CR>')
