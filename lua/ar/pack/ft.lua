ar.pack.add({
  {
    src = 'https://github.com/razak17/slides.nvim',
    ft = { 'slide' },
    cond = function() return ar.get_plugin_cond('slides.nvim') end,
  },
  {
    src = 'https://github.com/fladson/vim-kitty',
    ft = { 'kitty' },
    cond = function() return ar.get_plugin_cond('vim-kitty') end,
  },
  {
    src = 'https://github.com/raimon49/requirements.txt.vim',
    cond = function()
      local condition = not ar.plugins.minimal and ar.plugins.niceties
      return ar.get_plugin_cond('requirements.txt.vim', condition)
    end,
    lazy = false,
  },
  {
    src = 'https://github.com/gennaro-tedesco/nvim-jqx',
    cond = function()
      return ar.get_plugin_cond('nvim-jqx', not ar.plugins.minimal)
    end,
    ft = { 'json', 'yaml' },
  },
})
