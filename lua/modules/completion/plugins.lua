local completion = {}
local conf = require 'modules.completion.config'

completion['liuchengxu/vim-which-key'] = {
  event = {"BufWinEnter"},
  config = conf.which_key,
  disable = not rvim.plugin.SANE.active,
}

completion['mattn/emmet-vim'] = {
  event = 'InsertEnter',
  config = conf.emmet,
  disable = not rvim.plugin.emmet.active,
}

completion['hrsh7th/nvim-compe'] = {
  event = "InsertEnter",
  config = conf.nvim_compe,
  disable = not rvim.plugin.SANE.active,
}

completion['rafamadriz/friendly-snippets'] = {
  event = 'InsertEnter',
  disable = not rvim.plugin.friendly_snippets.active,
}

completion['hrsh7th/vim-vsnip'] = {
  event = "InsertEnter",
  config = function() vim.g.vsnip_snippet_dir = rvim.__vsnip_dir end,
  disable = not rvim.plugin.vsnip.active,
}

completion['nvim-lua/plenary.nvim'] = {disable = not rvim.plugin.SANE.active}

completion['nvim-lua/popup.nvim'] = {disable = not rvim.plugin.SANE.active}

completion['nvim-telescope/telescope.nvim'] = {
  config = conf.telescope,
  disable = not rvim.plugin.SANE.active,
}

completion['nvim-telescope/telescope-fzy-native.nvim'] = {
  opt = true,
  disable = not rvim.plugin.telescope_fzy.active,
}

completion['nvim-telescope/telescope-media-files.nvim'] = {
  opt = true,
  disable = not rvim.plugin.telescope_media_files.active,
}

completion['nvim-telescope/telescope-project.nvim'] = {
  opt = true,
  disable = not rvim.plugin.telescope_project.active,
}

return completion
