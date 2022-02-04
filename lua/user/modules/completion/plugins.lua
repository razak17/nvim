local completion = {}

local utils = require "user.utils"

completion["folke/which-key.nvim"] = {
  config = utils.load_conf("completion", "which_key"),
  disable = not rvim.plugin.which_key.active,
}

completion["mattn/emmet-vim"] = {
  config = function()
    vim.g.user_emmet_complete_tag = 0
    vim.g.user_emmet_install_global = 0
    vim.g.user_emmet_install_command = 0
    vim.g.user_emmet_mode = "i"
    vim.cmd "autocmd FileType html,css EmmetInstall"
  end,
  disable = not rvim.plugin.emmet.active,
}

completion["hrsh7th/nvim-cmp"] = {
  config = utils.load_conf("completion", "cmp"),
  requires = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
  },
  commit = rvim.plugin.commits.nvim_cmp,
  disable = not rvim.plugin.cmp.active,
}

completion["hrsh7th/vim-vsnip"] = {
  config = function()
    vim.g.vsnip_snippet_dir = rvim.common.snippets_dir
  end,
  disable = not rvim.plugin.vsnip.active,
}

completion["rafamadriz/friendly-snippets"] = {
  event = "InsertEnter",
  disable = not rvim.plugin.friendly_snippets.active,
}

completion["nvim-lua/plenary.nvim"] = { disable = not rvim.plugin.plenary.active }

completion["nvim-lua/popup.nvim"] = { disable = not rvim.plugin.popup.active }

-- Telescope
completion["razak17/telescope.nvim"] = {
  event = "VimEnter",
  config = utils.load_conf("completion", "telescope"),
  disable = not rvim.plugin.telescope.active,
}

completion["nvim-telescope/telescope-fzf-native.nvim"] = {
  run = "make",
  disable = not rvim.plugin.telescope_fzf.active,
}

completion["nvim-telescope/telescope-ui-select.nvim"] = {
  disable = not rvim.plugin.telescope_ui_select.active,
}

completion["camgraff/telescope-tmux.nvim"] = {
  disable = not rvim.plugin.telescope_ui_select.active,
}

completion["tami5/sqlite.lua"] = { disable = not rvim.plugin.telescope_frecency.active }

completion["nvim-telescope/telescope-frecency.nvim"] = {
  disable = not rvim.plugin.telescope_frecency.active,
}

return completion
