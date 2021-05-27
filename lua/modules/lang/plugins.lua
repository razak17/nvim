local lang = {}
local conf = require('modules.lang.config')

lang['glepnir/lspsaga.nvim'] = {event = "BufReadPre"}

lang['mfussenegger/nvim-dap'] = {config = conf.dap}

lang['rcarriga/nvim-dap-ui'] = {config = conf.dap_ui}

lang['andymass/vim-matchup'] = {ft = {'html'}}

lang['kevinhwang91/nvim-bqf'] = {
  event = 'VimEnter',
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

lang['p00f/nvim-ts-rainbow'] = {opt = true, after = 'nvim-treesitter'}

lang['ray-x/lsp_signature.nvim'] = {event = 'BufReadPre'}

lang['neovim/nvim-lspconfig'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.nvim_lsp
}

lang['nvim-treesitter/nvim-treesitter'] =
    {event = 'BufRead', after = 'telescope.nvim', config = conf.nvim_treesitter}

lang['windwp/nvim-ts-autotag'] = {
  opt = true,
  after = 'nvim-treesitter',
  event = "InsertLeavePre"
}

lang['simrat39/symbols-outline.nvim'] = {
  event = 'BufReadPre',
  cmd = 'SymbolsOutline',
  config = function()
    require("symbols-outline").setup {show_guides = true}
  end
}

lang['folke/trouble.nvim'] = {
  event = 'BufReadPre',
  requires = {{"kyazdani42/nvim-web-devicons", opt = true}},
  config = function()
    require("trouble").setup {use_lsp_diagnostic_signs = true}
  end
}

return lang
