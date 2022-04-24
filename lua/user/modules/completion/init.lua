local completion = {}

rvim.plugins.completion = {
  which_key = { active = true },
  cmp = { active = true },
  luasnip = { active = true },
  friendly_snippets = { active = true },
  copilot = { active = true },
}

local load_conf = require("user.utils").load_conf

completion["folke/which-key.nvim"] = {
  config = load_conf("completion", "which_key"),
  disable = not rvim.plugins.completion.which_key.active,
}

-- nvim-cmp
completion["hrsh7th/nvim-cmp"] = {
  branch = "dev",
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
  config = function()
    vim.g.copilot_no_tab_map = true
    vim.cmd [[imap <silent><script><expr> <C-l> copilot#Accept("\<CR>")]]

    -- https://github.com/akinsho/dotfiles/commit/4b0f52e24058ad8d22bcbf5ee64ebcb476a79536
    -- rvim.imap("<Plug>(rvim:copilot-accept)", "copilot#Accept('<CR>')", { expr = true })
    rvim.inoremap("<M-]>", "<Plug>(copilot-next)")
    rvim.inoremap("<M-[>", "<Plug>(copilot-previous)")
    rvim.inoremap("<C-\\>", "<Cmd>vertical Copilot panel<CR>")

    vim.g.copilot_filetypes = {
      ["*"] = true,
      gitcommit = false,
      NeogitCommitMessage = false,
      DressingInput = false,
      ["neo-tree-popup"] = false,
    }
    require("zephyr.util").plugin("copilot", { CopilotSuggestion = { link = "Comment" } })
  end,
  disable = not rvim.plugins.completion.copilot.active,
}

return completion
