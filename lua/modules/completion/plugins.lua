local completion = {}
local conf = require 'modules.completion.config'

completion['liuchengxu/vim-which-key'] =
    {
      config = function()
        require 'keymap.which_key'
      end
    }

completion['hrsh7th/vim-vsnip'] = {
  event = 'InsertCharPre',
  requires = {'hrsh7th/vim-vsnip-integ', 'rafamadriz/friendly-snippets'},
  config = conf.vim_vsnip
}

completion['mattn/emmet-vim'] = {
  event = 'InsertEnter',
  ft = {
    'html',
    'css',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact'
  },
  config = conf.emmet
}

completion['nvim-telescope/telescope.nvim'] =
    {
      requires = {
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-fzy-native.nvim',
        'razak17/telescope-packer.nvim',
        'nvim-telescope/telescope-media-files.nvim'
      },
      config = conf.telescope_nvim
    }

return completion

