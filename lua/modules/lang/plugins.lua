local conf = require('modules.lang.config')

local lang = {}

-- Debug
lang['mfussenegger/nvim-dap'] = {
  event = 'BufReadPre',
  config = conf.dap,
  disable = not core.plugin.debug.active,
}

lang['rcarriga/nvim-dap-ui'] = {
  event = 'BufReadPre',
  config = conf.dap_ui,
  disable = not core.plugin.debug_ui.active,
}

lang['Pocco81/DAPInstall.nvim'] = {
  event = 'BufReadPre',
  config = conf.dap_install,
  disable = not core.plugin.dap_install.active,
}

lang['jbyuki/one-small-step-for-vimkind'] = {
  event = 'BufReadPre',
  disable = not core.plugin.osv.active,
}

-- Lsp
lang['neovim/nvim-lspconfig'] = {config = conf.nvim_lsp, disable = not core.plugin.SANE.active}

lang['glepnir/lspsaga.nvim'] = {after = 'nvim-lspconfig', disable = not core.plugin.saga.active}

lang['jose-elias-alvarez/nvim-lsp-ts-utils'] = {
  ft = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  disable = not core.plugin.lsp_ts_utils.active
}

lang['mfussenegger/nvim-lint'] = {
  config = conf.nvim_lint,
  disable = not core.plugin.nvim_lint.active,
}

lang['kosayoda/nvim-lightbulb'] = {
  after = 'nvim-lspconfig',
  config = conf.lightbulb,
  disable = not core.plugin.lightbulb.active,
}

lang['simrat39/symbols-outline.nvim'] = {
  after = 'nvim-lspconfig',
  cmd = 'SymbolsOutline',
  config = function()
    require("symbols-outline").setup {show_guides = true}
  end,
  disable = not core.plugin.symbols_outline.active,
}

lang['folke/trouble.nvim'] = {
  after = 'nvim-lspconfig',
  requires = {{"kyazdani42/nvim-web-devicons", opt = true}},
  config = function()
    require("trouble").setup {use_lsp_diagnostic_signs = true}
  end,
  disable = not core.plugin.trouble.active,
}

lang['kevinhwang91/nvim-bqf'] = {
  after = 'telescope.nvim',
  config = conf.bqf,
  disable = not core.plugin.bqf.active,
}

-- Treesitter
lang['nvim-treesitter/nvim-treesitter'] = {
  event = 'BufWinEnter',
  after = 'telescope.nvim',
  config = conf.nvim_treesitter,
  disable = not core.plugin.treesitter.active and not core.plugin.SANE.active,
}

lang['nvim-treesitter/playground'] = {
  cmd = "TSPlaygroundToggle",
  module = "nvim-treesitter-playground",
  disable = not core.plugin.playground.active,
}

lang['p00f/nvim-ts-rainbow'] = {after = 'nvim-treesitter', disable = not core.plugin.rainbow.active}

lang['andymass/vim-matchup'] = {
  event = 'VimEnter',
  after = 'nvim-treesitter',
  disable = not core.plugin.matchup.active,
}

lang['windwp/nvim-ts-autotag'] = {
  after = 'nvim-treesitter',
  event = "InsertLeavePre",
  disable = not core.plugin.autotag.active,
}

lang['windwp/nvim-autopairs'] = {
  event = 'InsertEnter',
  after = {"telescope.nvim"},
  config = conf.autopairs,
  disable = not core.plugin.autopairs.active,
}

return lang
