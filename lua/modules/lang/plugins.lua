local lang = {}
local conf = require('modules.lang.config')

lang['neovim/nvim-lspconfig'] = {
  event = 'BufReadPre',
  requires = {'tjdevries/lsp_extensions.nvim'},
  config = conf.nvim_lsp
}

lang['glepnir/lspsaga.nvim'] = {cmd = 'Lspsaga'}

lang['nvim-treesitter/nvim-treesitter'] =
    {
      run = ':TSUpdate',
      event = 'BufRead',
      after = 'telescope.nvim',
      requires = {{'romgrk/nvim-treesitter-context', after = 'nvim-treesitter'}},
      config = conf.nvim_treesitter
    }

lang['nvim-treesitter/nvim-treesitter-textobjects'] =
    {after = 'nvim-treesitter'}

lang['elixir-editors/vim-elixir'] = {ft = {'elixir'}}

lang['mfussenegger/nvim-dap'] = {config = conf.dap}

return lang

