local lang = {}
local conf = require('modules.lang.config')

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

return lang

