local minimal = ar.plugins.minimal

return {
  { 'will133/vim-dirdiff', cmd = { 'DirDiff' } },
  {
    'AndrewRadev/linediff.vim',
    cond = function() return ar.get_plugin_cond('linediff.vim', not minimal) end,
    cmd = 'Linediff',
    keys = {
      { '<localleader>lL', '<cmd>Linediff<CR>', desc = 'linediff: toggle' },
    },
  },
}
