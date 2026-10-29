ar.pack.add({
  {
    src = 'https://github.com/Davidyz/VectorCode',
    cond = function() return ar.get_plugin_cond('VectorCode', ar.ai.enable) end,
    version = vim.version.range('*'),
    build = 'uv tool upgrade vectorcode',
    cmd = 'VectorCode',
    dependencies = {
      { src = 'https://github.com/nvim-lua/plenary.nvim' },
    },
  },
})
