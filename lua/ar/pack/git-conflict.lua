local git_cond = require('ar.utils.git').git_cond

ar.pack.add({
  {
    src = 'https://github.com/spacedentist/resolve.nvim',
    cond = function() return git_cond('resolve.nvim') end,
    event = { 'BufReadPre', 'BufNewFile' },
    -- stylua: ignore
    keys = function(load)
      local function jump(options)
        return ar.jump(function(opt)
          load()
          if opt.forward then require('resolve').next_conflict() end
          if not opt.forward then require('resolve').prev_conflict() end
        end, options)
      end
      map('n', ']x', jump({ forward = true }), { desc = 'resolve: next conflict' })
      map('n', '[x', jump({ forward = false }), { desc = 'resolve: prev conflict' })
      return {
        { '<leader>g?n', '<Cmd>ResolveNext<CR>', desc = 'resolve: next conflict' },
        { '<leader>g?p', '<Cmd>ResolvePrev<CR>', desc = 'resolve: previous conflict' },
        { '<leader>g?<', '<Cmd>ResolveOurs<CR>', desc = 'resolve: choose ours' },
        { '<leader>g?>', '<Cmd>ResolveTheirs<CR>', desc = 'resolve: choose theirs' },
        { '<leader>g?=', '<Cmd>ResolveBoth<CR>', desc = 'resolve: choose both' },
        { '<leader>g?b', '<Cmd>ResolveBase<CR>', desc = 'resolve: choose base' },
        { '<leader>g?m', '<Cmd>ResolveDetect<CR>', desc = 'resolve: manually detect' },
        { '<leader>g?n', '<Cmd>ResolveNone<CR>', desc = 'resolve: choose none' },
        { '<leader>g?q', '<Cmd>ResolveList<CR>', desc = 'resolve: list in qflist' },
        { '<leader>g?r', '<Cmd>ResolveBothReverse<CR>', desc = 'resolve: choose both reverse' },
      }
    end,
    init = function()
      vim.g.whichkey_add_spec({ '<leader>g?', group = 'Git conflicts' })
    end,
    setup = function()
      require('resolve').setup({
        default_keymaps = false,
        markers = {
          ours = '^<<<<<<<+', -- Start of "ours" section
          theirs = '^>>>>>>>+', -- End of "theirs" section
          ancestor = '^|||||||+', -- Start of ancestor/base section (diff3)
          separator = '^=======+$', -- Separator between sections
        },
      })
    end,
  },
  -- FIX: Causes performance issues in large folds (~1000+ lines)
  {
    src = 'https://github.com/TungstnBallon/conflict.nvim',
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
    src = 'https://github.com/akinsho/git-conflict.nvim',
    cond = git_cond('git-conflict.nvim'),
    event = 'BufReadPre',
    setup = function()
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
      require('git-conflict').setup({
        disable_diagnostics = true,
        default_mappings = {
          ours = 'c<',
          theirs = 'c>',
          none = 'co',
          both = 'c.',
          next = ']x',
          prev = '[x',
        },
      })
    end,
  },
})
