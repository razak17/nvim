local completion = {}

rvim.plugins.completion = {
  which_key = { active = true },
  cmp = { active = true },
  luasnip = { active = true },
  friendly_snippets = { active = true },
  copilot = { active = true },
}

local utils = require "user.utils"
local load_conf = utils.load_conf

completion["folke/which-key.nvim"] = {
  config = load_conf("completion", "which_key"),
  disable = not rvim.plugins.completion.which_key.active,
}

-- nvim-cmp
completion["hrsh7th/nvim-cmp"] = {
  event = "InsertEnter",
  config = load_conf("completion", "cmp"),
  disable = not rvim.plugins.completion.cmp.active,
}

completion["L3MON4D3/LuaSnip"] = {
  event = "InsertEnter",
  config = load_conf("completion", "luasnip"),
  disable = not rvim.plugins.completion.luasnip.active,
}

completion["rafamadriz/friendly-snippets"] = {
  event = "InsertEnter",
  disable = not rvim.plugins.completion.friendly_snippets.active,
}

completion["hrsh7th/cmp-nvim-lsp"] = {
  event = "InsertEnter",
  disable = not rvim.plugins.completion.cmp.active,
}

completion["hrsh7th/cmp-nvim-lua"] = {
  event = "InsertEnter",
  disable = not rvim.plugins.completion.cmp.active,
}

completion["hrsh7th/cmp-nvim-lsp-document-symbol"] = {
  event = "InsertEnter",
  disable = not rvim.plugins.completion.cmp.active,
}

completion["saadparwaiz1/cmp_luasnip"] = {
  event = "InsertEnter",
  disable = not rvim.plugins.completion.cmp.active,
}

completion["hrsh7th/cmp-buffer"] = {
  event = "InsertEnter",
  disable = not rvim.plugins.completion.cmp.active,
}

completion["hrsh7th/cmp-path"] = {
  event = "InsertEnter",
  disable = not rvim.plugins.completion.cmp.active,
}

completion["hrsh7th/cmp-cmdline"] = {
  event = "InsertEnter",
  disable = not rvim.plugins.completion.cmp.active,
}

completion["f3fora/cmp-spell"] = {
  event = "InsertEnter",
  disable = not rvim.plugins.completion.cmp.active,
}

completion["hrsh7th/cmp-emoji"] = {
  event = "InsertEnter",
  disable = not rvim.plugins.completion.cmp.active,
}

completion["octaltree/cmp-look"] = {
  event = "InsertEnter",
  disable = not rvim.plugins.completion.cmp.active,
}

completion["petertriho/cmp-git"] = {
  opt = true,
  config = function()
    require("cmp_git").setup {
      filetypes = { "gitcommit", "NeogitCommitMessage" },
    }
  end,
  disable = not rvim.plugins.completion.cmp.active,
}

completion["David-Kunz/cmp-npm"] = {
  opt = true,
  config = function()
    require("cmp-npm").setup {}
  end,
  disable = not rvim.plugins.completion.cmp.active,
}

completion["github/copilot.vim"] = {
  opt = true,
  config = function()
    vim.g.copilot_no_tab_map = true
    vim.cmd [[imap <silent><script><expr> <C-l> copilot#Accept("\<CR>")]]
    vim.cmd [[let g:copilot_no_tab_map = v:true]]
    vim.g.copilot_filetypes = {
      ["*"] = true,
      gitcommit = false,
      NeogitCommitMessage = false,
    }
    require("zephyr.util").plugin("copilot", { CopilotSuggestion = { link = "Comment" } })
  end,
  disable = not rvim.plugins.completion.copilot.active,
}

return completion
