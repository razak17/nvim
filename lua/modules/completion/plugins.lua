local completion = {}
local conf = require 'modules.completion.config'

completion['rafamadriz/friendly-snippets'] = {event = 'InsertEnter'}

completion['liuchengxu/vim-which-key'] = {
  event = 'VimEnter',
  config = conf.which_key,
}

completion['hrsh7th/nvim-compe'] = {
  event = 'InsertEnter',
  config = conf.nvim_compe,
}

completion['mattn/emmet-vim'] = {event = 'InsertEnter', config = conf.emmet}

completion['hrsh7th/vim-vsnip'] = {
  event = 'InsertCharPre',
  config = function() vim.g.vsnip_snippet_dir = r17.__vim_path .. "/snippets" end,
}

completion['nvim-telescope/telescope.nvim'] = {
  cmd = 'Telescope',
  config = conf.telescope,
  requires = {
    {'nvim-lua/popup.nvim', opt = true},
    {'nvim-lua/plenary.nvim', opt = true},
    {'nvim-telescope/telescope-fzy-native.nvim', opt = true},
    {'nvim-telescope/telescope-media-files.nvim', opt = true},
    {'nvim-telescope/telescope-project.nvim', opt = true},
  },
}

return completion
