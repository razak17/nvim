local conf = require('modules.lang.config')

local lang = {}

lang['mfussenegger/nvim-dap'] = {config = conf.dap}

lang['rcarriga/nvim-dap-ui'] = {config = conf.dap_ui}

lang['neovim/nvim-lspconfig'] = {
  event = 'BufReadPre',
  config = conf.nvim_lsp,
  requires = {
    {'kosayoda/nvim-lightbulb', event = "BufReadPre"},
    {'glepnir/lspsaga.nvim', opt = true}
  }
}

-- lang['simrat39/symbols-outline.nvim'] = {
--   event = 'BufReadPre',
--   cmd = 'SymbolsOutline',
--   config = function()
--     require("symbols-outline").setup {show_guides = true}
--   end
-- }

lang['folke/trouble.nvim'] = {
  event = 'BufReadPre',
  requires = {{"kyazdani42/nvim-web-devicons", opt = true}},
  config = function()
    require("trouble").setup {use_lsp_diagnostic_signs = true}
  end
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
          '█'
        }
      }
    })
  end
}

lang['nvim-treesitter/nvim-treesitter'] =
    {
      event = 'BufRead',
      after = 'telescope.nvim',
      config = conf.nvim_treesitter,
      requires = {
        {
          "nvim-treesitter/playground",
          cmd = "TSPlaygroundToggle",
          module = "nvim-treesitter-playground"
        },
        {'p00f/nvim-ts-rainbow', after = 'nvim-treesitter'},
        {'andymass/vim-matchup', after = 'nvim-treesitter'},
        {
          'windwp/nvim-ts-autotag',
          opt = true,
          after = 'nvim-treesitter',
          event = "InsertLeavePre"
        }
      }
    }

return lang
