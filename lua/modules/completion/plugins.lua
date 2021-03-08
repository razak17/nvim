local completion = {}
local conf = require('modules.completion.conf')

completion['neovim/nvim-lspconfig'] = {
  event = 'BufReadPre',
  config = conf.nvim_lsp,
  requires = {
    {'tjdevries/lsp_extensions.nvim'},
    {'glepnir/lspsaga.nvim'},
    {'onsails/lspkind-nvim'},
  }
}

completion['hrsh7th/nvim-compe'] = {
  config = conf.nvim_compe,
}

completion['liuchengxu/vim-which-key'] = {}

completion['hrsh7th/vim-vsnip'] = {
  requires = {'hrsh7th/vim-vsnip-integ'},
  config = conf.vim_vsnip,
}

completion['mattn/emmet-vim'] = {
  event = 'InsertEnter',
  ft = {'html','css','javascript','javascriptreact','vue','typescript','typescriptreact'},
  config = conf.emmet,
}

completion['nvim-telescope/telescope.nvim'] = {
  config = conf.nvim_telescope,
  requires = {
    {'nvim-lua/popup.nvim'},
    {'nvim-lua/plenary.nvim'},
    {'nvim-telescope/telescope-fzy-native.nvim'},
    {'nvim-telescope/telescope-packer.nvim',opt = true},
  }
}

return completion

