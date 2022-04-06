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
  config = load_conf("completion", "cmp"),
  disable = not rvim.plugins.completion.cmp.active,
}

completion["L3MON4D3/LuaSnip"] = {
  config = load_conf("completion", "luasnip"),
  disable = not rvim.plugins.completion.luasnip.active,
}

completion["rafamadriz/friendly-snippets"] = {
  disable = not rvim.plugins.completion.friendly_snippets.active,
}

completion["hrsh7th/cmp-nvim-lsp"] = {
  disable = not rvim.plugins.completion.cmp.active,
}

completion["hrsh7th/cmp-nvim-lua"] = {
  disable = not rvim.plugins.completion.cmp.active,
}

completion["hrsh7th/cmp-nvim-lsp-document-symbol"] = {
  disable = not rvim.plugins.completion.cmp.active,
}

completion["saadparwaiz1/cmp_luasnip"] = {
  disable = not rvim.plugins.completion.cmp.active,
}

completion["hrsh7th/cmp-buffer"] = {
  disable = not rvim.plugins.completion.cmp.active,
}

completion["hrsh7th/cmp-path"] = {
  disable = not rvim.plugins.completion.cmp.active,
}

completion["hrsh7th/cmp-cmdline"] = {
  disable = not rvim.plugins.completion.cmp.active,
}

completion["f3fora/cmp-spell"] = {
  disable = not rvim.plugins.completion.cmp.active,
}

completion["hrsh7th/cmp-emoji"] = {
  disable = not rvim.plugins.completion.cmp.active,
}

completion["octaltree/cmp-look"] = {
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
      ["*"] = false,
      gitcommit = false,
      NeogitCommitMessage = false,
      dart = true,
      lua = true,
      python = true,
    }
    require("zephyr.util").plugin("copilot", { CopilotSuggestion = { link = "Comment" } })
  end,
  disable = not rvim.plugins.completion.copilot.active,
}

completion["zbirenbaum/copilot.lua"] = {
  event = "InsertEnter",
  config = function()
    vim.schedule(function()
      require "copilot"
    end)
  end,
}

completion["zbirenbaum/copilot-cmp"] = {
  after = { "copilot.lua", "nvim-cmp" },
}
return completion
