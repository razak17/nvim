local completion = {}
local conf = require 'modules.completion.config'

completion['liuchengxu/vim-which-key'] = {
  event = 'VimEnter',
  config = conf.which_key,
}

completion['rafamadriz/friendly-snippets'] = {event = 'InsertEnter'}

completion['mattn/emmet-vim'] = {
  event = 'InsertEnter',
  config = conf.emmet,
  disable = not core.plugin.emmet.active,
}

completion['hrsh7th/nvim-compe'] = {
  event = "InsertEnter",
  config = conf.nvim_compe,
}

completion['hrsh7th/vim-vsnip'] = {
  event = "InsertEnter",
  config = function() vim.g.vsnip_snippet_dir = core.__vsnip_dir end,
}

completion['nvim-lua/plenary.nvim'] = {opt = true}

completion['nvim-lua/popup.nvim'] = {opt = true}

completion['nvim-telescope/telescope.nvim'] = {
  -- cmd = 'Telescope',
  event = "BufRead",
  config = conf.telescope,
  requires = {},
}
completion['nvim-telescope/telescope-fzy-native.nvim'] = {
  opt = true,
  disable = not core.plugin.telescope_fzy.active,
}

completion['nvim-telescope/telescope-media-files.nvim'] = {
  opt = true,
  disable = not core.plugin.telescope_media_files.active,
}

completion['nvim-telescope/telescope-project.nvim'] = {
  opt = true,
  disable = not core.plugin.telescope_project.active,
}

return completion
