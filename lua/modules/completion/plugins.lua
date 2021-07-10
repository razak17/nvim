local completion = {}
local conf = require 'modules.completion.config'

completion['liuchengxu/vim-which-key'] = {
  event = 'VimEnter',
  config = conf.which_key,
}

completion['rafamadriz/friendly-snippets'] = {event = 'InsertEnter'}

completion['mattn/emmet-vim'] = {event = 'InsertEnter', config = conf.emmet}

completion['hrsh7th/nvim-compe'] = {
  event = {'BufRead', 'BufNewFile'},
  config = conf.nvim_compe,
}

completion['hrsh7th/vim-vsnip'] = {
  event = {'BufRead', 'BufNewFile'},
  config = function() vim.g.vsnip_snippet_dir = core.utils.vsnip_dir end,
}

completion['nvim-telescope/telescope.nvim'] = {
  cmd = 'Telescope',
  config = conf.telescope,
  requires = {
    {'nvim-lua/popup.nvim', opt = true},
    {'nvim-lua/plenary.nvim', opt = true},
  },
}

completion['nvim-telescope/telescope-fzy-native.nvim'] = {
  opt = true,
  disable = not core.active.telescope_fzy,
}

completion['nvim-telescope/telescope-media-files.nvim'] = {
  opt = true,
  disable = not core.active.telescope_media_files,
}

completion['nvim-telescope/telescope-project.nvim'] = {
  opt = true,
  disable = not core.active.telescope_project,
}

return completion
