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
  module = "cmp",
  event = "InsertEnter",
  requires = {
    { "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" },
    { "hrsh7th/cmp-vsnip", after = "nvim-cmp" },
    { "hrsh7th/cmp-buffer", after = "nvim-cmp" },
    { "hrsh7th/cmp-path", after = "nvim-cmp" },
    { "f3fora/cmp-spell", after = "nvim-cmp" },
    {
      "petertriho/cmp-git",
      after = "nvim-cmp",
      config = function()
        require("cmp_git").setup {
          filetypes = { "gitcommit", "NeogitCommitMessage" },
        }
      end,
    },
  },
  commit = rvim.plugin.commits.nvim_cmp,
  config = utils.load_conf("completion", "cmp"),
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

return completion
