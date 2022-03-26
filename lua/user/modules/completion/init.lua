local completion = {}

rvim.plugins.completion = {
  which_key = { active = true },
  plenary = { active = true },
  popup = { active = true },
  cmp = { active = true },
  luasnip = { active = true },
  emmet = { active = true },
  friendly_snippets = { active = true },
}

local utils = require "user.utils"
local load_conf = utils.load_conf

completion["folke/which-key.nvim"] = {
  config = load_conf("completion", "which_key"),
  disable = not rvim.plugins.completion.which_key.active,
}

completion["mattn/emmet-vim"] = {
  config = function()
    vim.g.user_emmet_complete_tag = 0
    vim.g.user_emmet_install_global = 0
    vim.g.user_emmet_install_command = 0
    vim.g.user_emmet_mode = "i"
    vim.cmd "autocmd FileType html,css EmmetInstall"
  end,
  disable = not rvim.plugins.completion.emmet.active,
}

-- nvim-cmp
completion["hrsh7th/nvim-cmp"] = {
  module = "cmp",
  event = "InsertEnter",
  config = load_conf("completion", "cmp"),
  disable = not rvim.plugins.completion.cmp.active,
}

completion["hrsh7th/cmp-nvim-lsp"] = { after = "nvim-cmp" }

completion["hrsh7th/cmp-nvim-lua"] = { after = "nvim-cmp" }

completion["hrsh7th/cmp-nvim-lsp-document-symbol"] = { after = "nvim-cmp" }

completion["saadparwaiz1/cmp_luasnip"] = { after = "nvim-cmp" }

completion["hrsh7th/cmp-buffer"] = { after = "nvim-cmp" }

completion["hrsh7th/cmp-path"] = { after = "nvim-cmp" }

completion["hrsh7th/cmp-cmdline"] = { after = "nvim-cmp" }

completion["f3fora/cmp-spell"] = { after = "nvim-cmp" }

completion["hrsh7th/cmp-emoji"] = { after = "nvim-cmp" }

completion["octaltree/cmp-look"] = { after = "nvim-cmp" }

completion["petertriho/cmp-git"] = {
  opt = true,
  -- after = "nvim-cmp",
  config = function()
    require("cmp_git").setup {
      filetypes = { "gitcommit", "NeogitCommitMessage" },
    }
  end,
}

completion["David-Kunz/cmp-npm"] = {
  config = function()
    require("cmp-npm").setup {}
  end,
}

completion["github/copilot.vim"] = {
  "github/copilot.vim",
  config = function()
    vim.g.copilot_no_tab_map = true
    vim.cmd [[imap <expr> <Plug>(vimrc:copilot-dummy-map) copilot#Accept("\<Tab>")]]
    vim.g.copilot_filetypes = {
      ["*"] = false,
      gitcommit = false,
      NeogitCommitMessage = false,
      dart = true,
      lua = true,
    }
    require("zephyr.util").plugin("copilot", { "CopilotSuggestion", { link = "Comment" } })
  end,
}

completion["L3MON4D3/LuaSnip"] = {
  config = load_conf("completion", "luasnip"),
  disable = not rvim.plugins.completion.luasnip.active,
}

completion["rafamadriz/friendly-snippets"] = {
  event = "InsertEnter",
  disable = not rvim.plugins.completion.friendly_snippets.active,
}

completion["nvim-lua/plenary.nvim"] = { disable = not rvim.plugins.completion.plenary.active }

completion["nvim-lua/popup.nvim"] = { disable = not rvim.plugins.completion.popup.active }

return completion
