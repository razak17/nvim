return {
  {
    'razak17/software-licenses.nvim',
    cmd = { 'SoftwareLicenses' },
    cond = function() return ar.get_plugin_cond('software-licenses.nvim') end,
  },
}
