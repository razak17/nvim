ar.pack.add({
  {
    src = 'https://github.com/will133/vim-dirdiff',
    cmd = { 'DirDiff' },
    cond = function() return ar.get_plugin_cond('vim-dirdiff') end,
  },
  {
    src = 'https://github.com/AndrewRadev/linediff.vim',
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
})
