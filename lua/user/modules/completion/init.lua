local completion = {}

rvim.plugins.completion = {}

local conf = require("user.utils").load_conf
local plug_utils = require("user.utils.plugins")
local module = "completion"

local enabled = {
  "which_key",
  "cmp",
  "luasnip",
  "friendly_snippets",
  "vim_copilot",
}
plug_utils.enable_plugins(module, enabled)

local disabled = { "copilot" }
plug_utils.disable_plugins(module, disabled)

completion["folke/which-key.nvim"] = {
  config = conf(module, "which_key"),
  disable = not rvim.plugins.completion.which_key.active,
}

-- nvim-cmp
completion["hrsh7th/nvim-cmp"] = {
  config = conf(module, "cmp"),
  disable = not rvim.plugins.completion.cmp.active,
}

completion["L3MON4D3/LuaSnip"] = {
  module = "luasnip",
  requires = "rafamadriz/friendly-snippets",
  config = conf(module, "luasnip"),
  disable = not rvim.plugins.completion.luasnip.active,
}

completion["zbirenbaum/copilot-cmp"] = {
  module = "copilot_cmp",
  disable = not rvim.plugins.completion.copilot.active,
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
    require("cmp_git").setup({
      filetypes = { "gitcommit", "NeogitCommitMessage" },
    })
  end,
}

completion["David-Kunz/cmp-npm"] = {
  opt = true,
  config = function()
    require("cmp-npm").setup({})
  end,
}

completion["uga-rosa/cmp-dictionary"] = {
  event = "InsertEnter",
}

completion["dmitmel/cmp-cmdline-history"] = {
  event = "InsertEnter",
}

completion["github/copilot.vim"] = {
  config = function()
    vim.g.copilot_no_tab_map = true
    rvim.imap("<Plug>(rvim-copilot-accept)", "copilot#Accept('<Tab>')", { expr = true })
    rvim.inoremap("<M-]>", "<Plug>(copilot-next)")
    rvim.inoremap("<M-[>", "<Plug>(copilot-previous)")
    rvim.inoremap("<C-\\>", "<Cmd>vertical Copilot panel<CR>")

    vim.g.copilot_filetypes = {
      ["*"] = true,
      gitcommit = false,
      NeogitCommitMessage = false,
      DressingInput = false,
      TelescopePrompt = false,
      ["neo-tree-popup"] = false,
      ["dap-repl"] = false,
    }
    require("user.utils.highlights").plugin("copilot", { CopilotSuggestion = { link = "Comment" } })
  end,
  disable = not rvim.plugins.completion.vim_copilot.active,
}

completion["zbirenbaum/copilot.lua"] = {
  event = { "VimEnter" },
  config = function()
    require("copilot").setup({
      cmp = {
        enabled = true,
        method = "getPanelCompletions",
      },
      panel = { -- no config options yet
        enabled = true,
      },
      ft_disable = {
        "markdown",
        "gitcommit",
        "NeogitCommitMessage",
        "DressingInput",
        "TelescopePrompt",
        "neo-tree-popup",
        "dap-repl",
      },
    })
  end,
  disable = not rvim.plugins.completion.copilot.active,
}

return completion
