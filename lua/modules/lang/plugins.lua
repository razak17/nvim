local lang = {}
local conf = require('modules.lang.config')

lang['mfussenegger/nvim-dap'] = {config = conf.dap}

lang['rcarriga/nvim-dap-ui'] = {config = conf.dap_ui}

lang['kevinhwang91/nvim-bqf'] = {event = {'BufReadPre'}, config = conf.bqf}

lang['nvim-treesitter/nvim-treesitter'] =
    {event = 'VimEnter', after = 'telescope.nvim', config = conf.treesitter}

lang['neovim/nvim-lspconfig'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.nvim_lsp
}

lang['glepnir/lspsaga.nvim'] = {
  event = {'BufReadPre', 'BufNewFile'},
  cmd = 'Lspsaga'
}

lang['liuchengxu/vista.vim'] = {
  event = {'BufReadPre', 'BufNewFile'},
  cmd = 'Vista',
  config = conf.vim_vista
}

lang['simrat39/symbols-outline.nvim'] = {
  event = {'BufReadPre', 'BufNewFile'},
  cmd = 'SymbolsOutline',
  config = conf.symbols
}

lang['folke/trouble.nvim'] = {
  event = {'BufReadPre', 'BufNewFile'},
  requires = "kyazdani42/nvim-web-devicons",
  config = conf.trouble
}

lang['windwp/nvim-ts-autotag'] = {
  opt = true,
  event = "InsertLeavePre",
  after = 'nvim-treesitter'
}

return lang

