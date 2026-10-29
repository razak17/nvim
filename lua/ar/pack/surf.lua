ar.pack.add({
  {
    src = 'https://github.com/alex-popov-tech/store.nvim',
    cmd = 'Store',
    cond = function()
      return ar.get_plugin_cond('store.nvim', not ar.plugins.minimal)
    end,
  },
  {
    src = 'https://github.com/neuromaancer/readup.nvim',
    cond = function() return ar.get_plugin_cond('readup.nvim') end,
    cmd = { 'Readup', 'ReadupBrowser' },
    setup = function() require('readup').setup({ float = true }) end,
  },
})
