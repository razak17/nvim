ar.pack.add({
  {
    src = 'https://github.com/josephburgess/nvumi',
    cmd = { 'Nvumi' },
    cond = function() return ar.get_plugin_cond('nvumi') end,
    setup = function() require('nvumi').setup() end,
  },
})
