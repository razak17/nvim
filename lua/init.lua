require 'setup'
require 'conf'
require 'opts'
require 'plugins'
require 'binds'

if vim.fn.exists('vim.g.vscode') == 0 then
  require 'autocmd'
  require 'hijackc'
  require 'formatter'.setup()
  require 'lsp/setup'
  require 'plugin/onedark'
  require 'plugin/colorizer'
  require 'plugin/floaterm'
  require 'plugin/tagalong'
  require 'plugin/vim-cool'
  require 'plugin/telescope'
  require 'plugin/nvim-tree'
  require 'plugin/ultisnips'
  require 'plugin/vim-illuminate'
end
