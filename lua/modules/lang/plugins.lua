local conf = require('modules.lang.config')

local lang = {}

lang['mfussenegger/nvim-dap'] = {
  event = "BufWinEnter",
  config = conf.dap,
  disable = not core.plugin.debug.active,
}

lang['rcarriga/nvim-dap-ui'] = {
  event = "BufWinEnter",
  config = conf.dap_ui,
  disable = not core.plugin.debug.active,
}

lang['Pocco81/DAPInstall.nvim'] = {
  event = "BufWinEnter",
  config = conf.dapinstall,
  disable = not core.plugin.dapinstall.active,
}

lang['neovim/nvim-lspconfig'] = {
  event = 'BufReadPre',
  config = conf.nvim_lsp,
  requires = {
    {'kosayoda/nvim-lightbulb', event = "BufReadPre"},
    {'glepnir/lspsaga.nvim', opt = true},
  },
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
  config = function()
    require('bqf').setup({
      preview = {
        border_chars = {
          '│',
          '│',
          '─',
          '─',
          '┌',
          '┐',
          '└',
          '┘',
          '█',
        },
      },
    })
  end,
  disable = not core.plugin.bfq.active,
}

lang['nvim-treesitter/nvim-treesitter'] = {
  event = 'BufRead',
  after = 'telescope.nvim',
  config = conf.nvim_treesitter,
}

lang['nvim-treesitter/playground'] = {
  cmd = "TSPlaygroundToggle",
  module = "nvim-treesitter-playground",
}

lang['p00f/nvim-ts-rainbow'] = {
  after = 'nvim-treesitter',
  disable = not core.plugin.rainbow.active,
}

lang['andymass/vim-matchup'] = {
  after = 'nvim-treesitter',
  disable = not core.plugin.matchup.active,
}

lang['windwp/nvim-ts-autotag'] = {
  opt = true,
  after = 'nvim-treesitter',
  event = "InsertLeavePre",
  disable = not core.plugin.autotag.active,
}

return lang
