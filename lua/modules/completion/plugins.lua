local completion = {}
local conf = require 'modules.completion.config'

completion['hrsh7th/nvim-compe'] = {
  event = 'InsertEnter',
  config = conf.nvim_compe
}

completion['liuchengxu/vim-which-key'] = {config = conf.which_key}

completion['hrsh7th/vim-vsnip'] = {
  event = 'InsertCharPre',
  config = conf.vim_vsnip
}

completion['rafamadriz/friendly-snippets'] =
    {
      event = 'InsertEnter',
      ft = {
        'c',
        'html',
        'css',
        'javascript',
        'javascriptreact',
        'typescript',
        'python',
        'typescriptreact'
      }
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
      cmd = 'Telescope',
      config = conf.telescope_nvim,
      requires = {
        {'nvim-lua/popup.nvim', opt = true},
        {'nvim-lua/plenary.nvim', opt = true},
        {'nvim-telescope/telescope-fzy-native.nvim', opt = true},
        {'razak17/telescope-packer.nvim', opt = true},
        {'nvim-telescope/telescope-media-files.nvim', opt = true},
        {'nvim-telescope/telescope-dap.nvim', opt = true},
        {'nvim-telescope/telescope-project.nvim', opt = true}
      }
    }

return completion
