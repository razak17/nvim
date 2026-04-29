return {
  ------------------------------------------------------------------------------
  -- Core {{{1
  ------------------------------------------------------------------------------
  'rosstang/lunajson.nvim',
  'b0o/schemastore.nvim',
  {
    'razak17/lspkind.nvim',
    config = function() require('lspkind').init({ preset = 'codicons' }) end,
    cond = function() return ar.get_plugin_cond('lspkind.nvim') end,
  },
  {
    'razak17/software-licenses.nvim',
    cmd = { 'SoftwareLicenses' },
    cond = function() return ar.get_plugin_cond('software-licenses.nvim') end,
  },
}
