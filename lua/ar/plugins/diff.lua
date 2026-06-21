return {
  {
    'will133/vim-dirdiff',
    cmd = { 'DirDiff' },
    cond = function() return ar.get_plugin_cond('vim-dirdiff') end,
  },
  {
    'AndrewRadev/linediff.vim',
    cond = function() return ar.get_plugin_cond('linediff.vim') end,
    cmd = {
      'Linediff',
      'LinediffAdd',
      'LinediffPick',
      'LinediffLast',
      'LinediffMerge',
      'LinediffReset',
    },
  },
}
