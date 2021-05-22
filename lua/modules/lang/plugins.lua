local lang = {}
local conf = require('modules.lang.config')

lang['glepnir/lspsaga.nvim'] = {cmd = 'Lspsaga'}

lang['mfussenegger/nvim-dap'] = {config = conf.dap}

lang['rcarriga/nvim-dap-ui'] = {config = conf.dap_ui}

lang['andymass/vim-matchup'] = {event = 'BufReadPre'}

lang['kevinhwang91/nvim-bqf'] = {event = 'BufReadPre'}

lang['p00f/nvim-ts-rainbow'] = {opt = true, after = 'nvim-treesitter'}

lang['neovim/nvim-lspconfig'] = {event = 'BufRead', config = conf.nvim_lsp}

lang['nvim-treesitter/nvim-treesitter'] =
    {event = 'BufRead', after = 'telescope.nvim', config = conf.treesitter}

lang['windwp/nvim-ts-autotag'] = {
  opt = true,
  after = 'nvim-treesitter',
  event = "InsertLeavePre"
}

lang['simrat39/symbols-outline.nvim'] = {
  event = 'BufRead',
  cmd = 'SymbolsOutline',
  config = function()
    require("symbols-outline").setup {show_guides = true}
  end
}

lang['folke/trouble.nvim'] = {
  event = 'BufRead',
  requires = "kyazdani42/nvim-web-devicons",
  config = function()
    require("trouble").setup {use_lsp_diagnostic_signs = true}
  end
}

return lang
