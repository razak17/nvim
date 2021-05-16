local lang = {}
local conf = require('modules.lang.config')

lang['neovim/nvim-lspconfig'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.nvim_lsp
}

lang['glepnir/lspsaga.nvim'] = {
  event = {'BufReadPre', 'BufNewFile'},
  cmd = 'Lspsaga'
}

lang['nvim-treesitter/nvim-treesitter'] =
    {
      event = 'VimEnter',
      after = 'telescope.nvim',
      config = conf.nvim_treesitter
    }

lang['mfussenegger/nvim-dap'] = {config = conf.dap}

lang['rcarriga/nvim-dap-ui'] = {config = conf.dap_ui}

return lang

