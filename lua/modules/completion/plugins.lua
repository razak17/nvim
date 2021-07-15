local completion = {}
local conf = require 'modules.completion.config'

completion['liuchengxu/vim-which-key'] = {
  event = {"BufWinEnter"},
  config = conf.which_key,
  disable = not core.plugin.SANE.active,
}

completion['rafamadriz/friendly-snippets'] = {
  event = 'InsertEnter',
  disable = not core.plugin.SANE.active,

}

completion['mattn/emmet-vim'] = {
  event = 'InsertEnter',
  config = conf.emmet,
  disable = not core.plugin.emmet.active,
}

completion['hrsh7th/nvim-compe'] = {
  event = "InsertEnter",
  config = conf.nvim_compe,
  disable = not core.plugin.SANE.active,
}

completion['hrsh7th/vim-vsnip'] = {
  event = "InsertEnter",
  config = function() vim.g.vsnip_snippet_dir = core.__vsnip_dir end,
  disable = not core.plugin.SANE.active,
}

completion['nvim-telescope/telescope.nvim'] = {
  config = conf.telescope,
  requires = {{'nvim-lua/plenary.nvim'}, {'nvim-lua/popup.nvim'}},
  disable = not core.plugin.SANE.active,
}

completion['nvim-telescope/telescope-fzy-native.nvim'] = {
  opt = true,
  disable = not core.plugin.telescope_fzy.active or not core.plugin.SANE.active,
}

completion['nvim-telescope/telescope-media-files.nvim'] = {
  opt = true,
  disable = not core.plugin.telescope_media_files.active or
    not core.plugin.SANE.active,
}

completion['nvim-telescope/telescope-project.nvim'] = {
  opt = true,
  disable = not core.plugin.telescope_project.active or
    not core.plugin.SANE.active,
}

return completion
