local conf = require "modules.lang.config"

local lang = {}

-- Debug
lang["mfussenegger/nvim-dap"] = {
  event = "BufReadPre",
  config = conf.dap,
  disable = not rvim.plugin.debug.active,
}

lang["rcarriga/nvim-dap-ui"] = {
  event = "BufReadPre",
  config = conf.dap_ui,
  disable = not rvim.plugin.debug_ui.active,
}

lang["Pocco81/DAPInstall.nvim"] = {
  event = "BufReadPre",
  config = conf.dap_install,
  disable = not rvim.plugin.dap_install.active,
}

lang["jbyuki/one-small-step-for-vimkind"] = {
  event = "BufReadPre",
  disable = not rvim.plugin.osv.active,
}

-- Lsp
lang["neovim/nvim-lspconfig"] = { config = conf.nvim_lsp, disable = not rvim.plugin.SANE.active }

lang["tamago324/nlsp-settings.nvim"] = {
  config = conf.nvim_lsp_settings,
  disable = not rvim.plugin.SANE.active,
}

lang["jose-elias-alvarez/null-ls.nvim"] = {
  config = conf.null_ls,
  disable = not rvim.plugin.SANE.active,
}

lang["glepnir/lspsaga.nvim"] = { after = "nvim-lspconfig", disable = not rvim.plugin.saga.active }

lang["jose-elias-alvarez/nvim-lsp-ts-utils"] = {
  ft = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  disable = not rvim.plugin.lsp_ts_utils.active,
}

lang["mhartington/formatter.nvim"] = {
  config = conf.formatter,
  disable = not rvim.plugin.formatter.active,
}

lang["mfussenegger/nvim-lint"] = {
  config = conf.nvim_lint,
  disable = not rvim.plugin.nvim_lint.active,
}

lang["kosayoda/nvim-lightbulb"] = {
  after = "nvim-lspconfig",
  config = conf.lightbulb,
  disable = not rvim.plugin.lightbulb.active,
}

lang["simrat39/symbols-outline.nvim"] = {
  after = "nvim-lspconfig",
  cmd = "SymbolsOutline",
  config = function()
    require("symbols-outline").setup { show_guides = true }
  end,
  disable = not rvim.plugin.symbols_outline.active,
}

lang["folke/trouble.nvim"] = {
  after = "nvim-lspconfig",
  requires = { { "kyazdani42/nvim-web-devicons", opt = true } },
  config = function()
    require("trouble").setup { use_lsp_diagnostic_signs = true }
  end,
  disable = not rvim.plugin.trouble.active,
}

lang["kevinhwang91/nvim-bqf"] = {
  after = "telescope.nvim",
  config = conf.bqf,
  disable = not rvim.plugin.bqf.active,
}

-- Treesitter
lang["nvim-treesitter/nvim-treesitter"] = {
  branch = "0.5-compat",
  -- after = 'telescope.nvim',
  config = conf.nvim_treesitter,
  disable = not rvim.plugin.treesitter.active and not rvim.plugin.SANE.active,
}

lang["nvim-treesitter/playground"] = {
  cmd = "TSPlaygroundToggle",
  module = "nvim-treesitter-playground",
  disable = not rvim.plugin.playground.active,
}

lang["p00f/nvim-ts-rainbow"] =
  { after = "nvim-treesitter", disable = not rvim.plugin.rainbow.active }

lang["andymass/vim-matchup"] = {
  event = "VimEnter",
  after = "nvim-treesitter",
  disable = not rvim.plugin.matchup.active,
}

lang["windwp/nvim-ts-autotag"] = {
  after = "nvim-treesitter",
  event = "InsertLeavePre",
  disable = not rvim.plugin.autotag.active,
}

lang["windwp/nvim-autopairs"] = {
  event = "InsertEnter",
  after = { "telescope.nvim" },
  config = conf.autopairs,
  disable = not rvim.plugin.autopairs.active,
}

return lang
