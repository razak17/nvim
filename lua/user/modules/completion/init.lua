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
  "copilot",
}
plug_utils.enable_plugins(module, enabled)

local disabled = {}
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
  event = "InsertEnter",
  module = "luasnip",
  requires = "rafamadriz/friendly-snippets",
  config = conf(module, "luasnip"),
  disable = not rvim.plugins.completion.luasnip.active,
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
    require("cmp_git").setup({
      filetypes = { "gitcommit", "NeogitCommitMessage" },
    })
  end,
  disable = not rvim.plugins.completion.cmp.active,
}

completion["David-Kunz/cmp-npm"] = {
  opt = true,
  config = function()
    require("cmp-npm").setup({})
  end,
  disable = not rvim.plugins.completion.cmp.active,
}

completion["uga-rosa/cmp-dictionary"] = {
  event = "InsertEnter",
  disable = not rvim.plugins.completion.cmp.active,
}

completion["dmitmel/cmp-cmdline-history"] = {
  event = "InsertEnter",
  disable = not rvim.plugins.completion.cmp.active,
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
    }
    require("user.utils.highlights").plugin("copilot", { CopilotSuggestion = { link = "Comment" } })
  end,
  disable = not rvim.plugins.completion.copilot.active,
}

return completion
