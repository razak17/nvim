local git_cond = require('ar.utils.git').git_cond

return {
  -- FIX: Causes performance issues in large folds (~1000+ lines)
  {
    'TungstnBallon/conflict.nvim',
    cond = function() return git_cond('conflict.nvim') end,
    event = { 'BufReadPre', 'BufNewFile' },
    -- stylua: ignore
    keys = {
      { '<leader>g?n', '<Plug>ConflictJumpToNext', desc = 'next conflict' },
      { '<leader>g?p', '<Plug>ConflictJumpToPrevious', desc = 'prev conflict' },
      { '<leader>g??', '<Plug>ConflictResolveAroundCursor', desc = 'resolve conflict' },
    },
  },
  {
    'akinsho/git-conflict.nvim',
    cond = git_cond('git-conflict.nvim'),
    event = 'BufReadPre',
    opts = {
      disable_diagnostics = true,
      default_mappings = {
        ours = 'c<',
        theirs = 'c>',
        none = 'co',
        both = 'c.',
        next = ']x',
        prev = '[x',
      },
    },
    config = function(_, opts)
      ar.highlight.plugin('git-conflict', {
        {
          theme = {
            ['onedark'] = {
              { GitConflictCurrent = { inherit = 'DiffAdd' } },
              { GitConflictCurrentLabel = { inherit = 'DiffAdd' } },
              { GitConflictIncoming = { inherit = 'DiffDelete' } },
              { GitConflictIncomingLabel = { inherit = 'DiffDelete' } },
              { GitConflictAncestor = { inherit = 'DiffText' } },
              { GitConflictAncestorLabel = { inherit = 'DiffText' } },
            },
          },
        },
      })
      require('git-conflict').setup(opts)
    end,
  },
}
