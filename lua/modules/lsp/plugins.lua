local lsp = {}
local conf = require 'modules.lsp.config'

lsp['neovim/nvim-lspconfig'] = {
  event = 'BufReadPre',
  requires = {'tjdevries/lsp_extensions.nvim'},
  config = conf.nvim_lsp
}

lsp['glepnir/lspsaga.nvim'] = {cmd = 'Lspsaga'}

return lsp
