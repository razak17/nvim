require'lsp.python'.format()
require'lsp.python'.lint()
require'lsp.python'.init()

core.nnoremap('<F10>', ':call v:lua.RunPython()<CR>')
