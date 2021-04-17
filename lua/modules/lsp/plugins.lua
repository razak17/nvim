local lsp = {}
local conf = require 'modules.lsp.config'

lsp['neovim/nvim-lspconfig'] = {
  event = 'BufReadPre',
  requires = {
    'tjdevries/lsp_extensions.nvim',
    'glepnir/lspsaga.nvim',
    'onsails/lspkind-nvim'
  },
  config = conf.nvim_lsp
}

lsp['kabouzeid/nvim-lspinstall'] = {}

lsp['mfussenegger/nvim-dap'] = {}

return lsp
