local conf = require "modules.lang.config"

local lang = {}

local function load_conf(name)
  return require(string.format("modules.lang.%s", name))
end

-- Debug
lang["mfussenegger/nvim-dap"] = {
  event = "BufReadPre",
  config = load_conf "dap",
  disable = not rvim.plugin.debug.active,
}

lang["rcarriga/nvim-dap-ui"] = {
  event = "BufReadPre",
  config = load_conf "dap_ui",
  disable = not rvim.plugin.debug_ui.active,
}

lang["Pocco81/DAPInstall.nvim"] = {
  event = "BufReadPre",
  config = conf.dap_install,
  disable = not rvim.plugin.dap_install.active,
}

lang["jbyuki/one-small-step-for-vimkind"] = {
  event = "BufReadPre",
  config = function()
    local nnoremap = rvim.nnoremap
    nnoremap("<leader>dl", ':lua require"osv".launch()<CR>')
  end,
  disable = not rvim.plugin.osv.active,
}

-- Lsp
lang["kabouzeid/nvim-lspinstall"] = {
  event = "VimEnter",
  config = function()
    local lspinstall = require "lspinstall"
    lspinstall.setup()
  end,
  disable = not rvim.plugin.SANE.active,
}
lang["neovim/nvim-lspconfig"] = { config = load_conf "lspconfig", disable = not rvim.plugin.SANE.active }

lang["tamago324/nlsp-settings.nvim"] = {
  config = conf.nvim_lsp_settings,
  disable = not rvim.plugin.SANE.active,
}

lang["jose-elias-alvarez/null-ls.nvim"] = {
  config = conf.null_ls,
  disable = not rvim.plugin.SANE.active,
}

lang["glepnir/lspsaga.nvim"] = { after = "nvim-lspconfig", disable = not rvim.plugin.saga.active }

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
    local nnoremap = rvim.nnoremap
    nnoremap("<Leader>vs", ":SymbolsOutline<CR>")
    require("symbols-outline").setup { show_guides = true }
  end,
  disable = not rvim.plugin.symbols_outline.active,
}

lang["folke/trouble.nvim"] = {
  after = "nvim-lspconfig",
  requires = { { "kyazdani42/nvim-web-devicons", opt = true } },
  config = function()
    local nnoremap = rvim.nnoremap
    nnoremap("<Leader>vxd", ":TroubleToggle lsp_document_diagnostics<CR>")
    nnoremap("<Leader>vxe", ":TroubleToggle quickfix<CR>")
    nnoremap("<Leader>vxl", ":TroubleToggle loclist<CR>")
    nnoremap("<Leader>vxr", ":TroubleToggle lsp_references<CR>")
    nnoremap("<Leader>vxw", ":TroubleToggle lsp_workspace_diagnostics<CR>")
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
  -- after = "telescope.nvim",
  config = load_conf "treesitter",
  disable = not rvim.plugin.treesitter.active and not rvim.plugin.SANE.active,
}

lang["nvim-treesitter/playground"] = {
  cmd = "TSPlaygroundToggle",
  config = function()
    local nnoremap = rvim.nnoremap
    nnoremap("<leader>aE", function()
      require("utils").inspect_token()
    end)
  end,
  module = "nvim-treesitter-playground",
  disable = not rvim.plugin.playground.active,
}

lang["p00f/nvim-ts-rainbow"] = { after = "nvim-treesitter", disable = not rvim.plugin.rainbow.active }

lang["andymass/vim-matchup"] = {
  event = "VimEnter",
  config = function()
    local nnoremap = rvim.nnoremap
    nnoremap("<Leader>vW", ":<c-u>MatchupWhereAmI?<CR>")
  end,
  after = "nvim-treesitter",
  disable = not rvim.plugin.matchup.active,
}

lang["windwp/nvim-ts-autotag"] = {
  after = "nvim-treesitter",
  event = "InsertLeavePre",
  disable = not rvim.plugin.autotag.active,
}

lang["windwp/nvim-autopairs"] = {
  -- event = "InsertEnter",
  -- after = { "telescope.nvim", "nvim-compe" },
  config = load_conf "autopairs",
  disable = not rvim.plugin.autopairs.active,
}

return lang
