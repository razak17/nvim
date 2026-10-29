ar.pack.add({
  {
    src = 'https://github.com/nvzone/typr',
    cond = function() return ar.get_plugin_cond('typr') end,
    cmd = 'TyprStats',
    dependencies = { { src = 'https://github.com/nvzone/volt' } },
    setup = function() require('typr').setup() end,
  },
})
