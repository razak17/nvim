return {
  {
    'nvzone/typr',
    cond = function() return ar.get_plugin_cond('typr') end,
    cmd = 'TyprStats',
    dependencies = 'nvzone/volt',
    opts = {},
  },
}
