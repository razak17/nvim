local completion = {}
local conf = require 'modules.completion.config'

completion['liuchengxu/vim-which-key'] = {event = 'VimEnter', config = conf.which_key}

completion['hrsh7th/nvim-compe'] = {
  event = 'InsertEnter',
  config = conf.nvim_compe
}

completion['hrsh7th/vim-vsnip'] = {
  event = 'InsertCharPre',
  config = function()
    local G = require 'core.global'
    vim.g.vsnip_snippet_dir = G.vim_path .. "/snippets"
  end
}

completion['nvim-telescope/telescope.nvim'] =
    {
      cmd = 'Telescope',
      config = conf.telescope,
      requires = {
        {'nvim-lua/popup.nvim', opt = true},
        {'nvim-lua/plenary.nvim', opt = true},
        {'nvim-telescope/telescope-fzy-native.nvim', opt = true},
        {'nvim-telescope/telescope-media-files.nvim', opt = true},
      }
    }

return completion
