return {
  {
    'Davidyz/VectorCode',
    cond = function() return ar.get_plugin_cond('VectorCode', ar.ai.enable) end,
    version = '*',
    build = 'uv tool upgrade vectorcode',
    cmd = 'VectorCode',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
}
