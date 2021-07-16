local conf = require('modules.lang.config')

local lang = {}

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

lang['neovim/nvim-lspconfig'] = {
  -- event = 'BufReadPre',
  -- event = 'BufWinEnter',
  -- event = {'BufRead', 'BufNewFile'},
  config = conf.nvim_lsp,
  disable = not core.plugin.SANE.active,
}

lang['glepnir/lspsaga.nvim'] = {
  opt = true,
  disable = not core.plugin.saga.active,
}

lang['kosayoda/nvim-lightbulb'] = {
  event = "BufReadPre",
  disable = not core.plugin.lightbulb.active,
}

lang['simrat39/symbols-outline.nvim'] = {
  event = 'BufReadPre',
  cmd = 'SymbolsOutline',
  config = function() require("symbols-outline").setup {show_guides = true} end,
  disable = not core.plugin.symbols_outline.active,
}

lang['folke/trouble.nvim'] = {
  event = 'BufReadPre',
  requires = {{"kyazdani42/nvim-web-devicons", opt = true}},
  config = function()
    require("trouble").setup {use_lsp_diagnostic_signs = true}
  end,
  disable = not core.plugin.trouble.active,
}

lang['kevinhwang91/nvim-bqf'] = {
  event = 'BufRead',
  after = 'telescope.nvim',
  config = conf.bqf,
  disable = not core.plugin.bqf.active,
}

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

lang['p00f/nvim-ts-rainbow'] = {
  event = 'VimEnter',
  after = 'nvim-treesitter',
  disable = not core.plugin.rainbow.active,
}

lang['andymass/vim-matchup'] = {
  event = 'VimEnter',
  after = 'nvim-treesitter',
  disable = not core.plugin.matchup.active,
}

lang['windwp/nvim-ts-autotag'] = {
  opt = true,
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
