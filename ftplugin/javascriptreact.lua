require'lsp.tsserver.format'.init()
require'lsp.tsserver.lint'.init()
require'lsp.tsserver'.init()

vim.cmd [[setlocal commentstring={/*%s*/}]]
