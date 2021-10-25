local completion = {}

local utils = require "utils"

completion["liuchengxu/vim-which-key"] = {
  event = { "BufWinEnter" },
  config = utils.load_conf("completion", "which_key"),
  disable = not rvim.plugin.which_key.active
}

completion["mattn/emmet-vim"] = {
  event = "InsertEnter",
  config = function()
    vim.g.user_emmet_complete_tag = 0
    vim.g.user_emmet_install_global = 0
    vim.g.user_emmet_install_command = 0
    vim.g.user_emmet_mode = "i"
  end,
  disable = not rvim.plugin.emmet.active,
}

completion["hrsh7th/nvim-compe"] = {
  event = "InsertEnter",
  config = utils.load_conf("completion", "compe"),
  disable = not rvim.plugin.compe.active
}

completion["rafamadriz/friendly-snippets"] = {
  event = "InsertEnter",
  disable = not rvim.plugin.friendly_snippets.active,
}

completion["hrsh7th/vim-vsnip"] = {
  event = "InsertEnter",
  config = utils.load_conf("completion", "vsnip"),
  disable = not rvim.plugin.vsnip.active,
}

completion["nvim-lua/plenary.nvim"] = { disable = not rvim.plugin.plenary.active }

completion["nvim-lua/popup.nvim"] = { disable = not rvim.plugin.popup.active }

-- Telescope
completion["nvim-telescope/telescope.nvim"] = {
  event = "BufReadPre",
  cmd = 'Telescope',
  config = utils.load_conf("completion", "telescope"),
  disable = not rvim.plugin.telescope.active,
}

completion["nvim-telescope/telescope-fzy-native.nvim"] = {
  opt = true,
  disable = not rvim.plugin.telescope_fzy.active,
}

completion["nvim-telescope/telescope-media-files.nvim"] = {
  opt = true,
  disable = not rvim.plugin.telescope_media_files.active,
}

completion["nvim-telescope/telescope-project.nvim"] = {
  opt = true,
  disable = not rvim.plugin.telescope_project.active,
}

return completion
