local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'razak17/slides.nvim',
    ft = 'slide',
    cond = function() return ar.get_plugin_cond('slides.nvim') end,
  },
  {
    'fladson/vim-kitty',
    ft = 'kitty',
    cond = function() return ar.get_plugin_cond('vim-kitty') end,
  },
  {
    'raimon49/requirements.txt.vim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('requirements.txt.vim', condition)
    end,
    lazy = false,
  },
  {
    'gennaro-tedesco/nvim-jqx',
    cond = function() return ar.get_plugin_cond('nvim-jqx', not minimal) end,
    ft = { 'json', 'yaml' },
  },
}
