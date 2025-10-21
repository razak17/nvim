local minimal = ar.plugins.minimal

return {
  {
    'alex-popov-tech/store.nvim',
    cmd = 'Store',
    cond = function() return ar.get_plugin_cond('store.nvim', not minimal) end,
  },
  {
    'neuromaancer/readup.nvim',
    cmd = { 'Readup', 'ReadupBrowser' },
    opts = { float = true },
  },
}
