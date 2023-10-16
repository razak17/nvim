local cwd = vim.fn.getcwd()
local icons = rvim.ui.icons
local border = rvim.ui.current.border
local left_block = icons.separators.left_block

return {
  {
    'NeogitOrg/neogit',
    cond = not rvim.plugins.minimal,
    cmd = 'Neogit',
    dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' },
    keys = {
      {
        '<localleader>gs',
        function() require('neogit').open() end,
        desc = 'open status buffer',
      },
      {
        '<localleader>gc',
        function() require('neogit').open({ 'commit' }) end,
        desc = 'open commit buffer',
      },
      {
        '<localleader>gl',
        function() require('neogit.popups.pull').create() end,
        desc = 'open pull popup',
      },
      {
        '<localleader>gp',
        function() require('neogit.popups.push').create() end,
        desc = 'open push popup',
      },
    },
    opts = {
      disable_signs = false,
      disable_hint = true,
      disable_commit_confirmation = true,
      disable_builtin_notifications = true,
      disable_insert_on_commit = false,
      disable_context_highlighting = true,
      signs = {
        section = { '', '󰘕' }, -- "󰁙", "󰁊"
        item = { '▸', '▾' },
        hunk = { '樂', '' },
      },
      integrations = {
        diffview = true,
      },
    },
    config = function(_, opts)
      rvim.highlight.plugin('neogit', {
        theme = {
          ['onedark'] = {
            { NeogitHunkHeader = { inherit = 'Headline2', bold = true } },
            { NeogitDiffHeader = { inherit = 'Headline2', bold = true } },
            { NeogitFold = { bg = { from = 'CursorLine', alter = -0.25 } } },
            {
              NeogitCursorLine = {
                bg = { from = 'CursorLine' },
                fg = { from = 'Normal' },
              },
            },
          },
        },
      })
      require('neogit').setup(opts)
    end,
  },
  {
    'sindrets/diffview.nvim',
    cond = not rvim.plugins.minimal,
    cmd = {
      'DiffviewOpen',
      'DiffviewFileHistory',
      'DiffviewToggleFiles',
      'DiffviewFocusFiles',
    },
    keys = {
      { '<localleader>gd', '<Cmd>DiffviewOpen<CR>', desc = 'diffview: open' },
      {
        'gh',
        [[:'<'>DiffviewFileHistory<CR>]],
        desc = 'diffview: file history',
        mode = 'v',
      },
      {
        '<localleader>gh',
        '<Cmd>DiffviewFileHistory<CR>',
        desc = 'diffview: file history',
      },
      {
        '<localleader>gx',
        '<cmd>set hidden<cr><cmd>DiffviewClose<cr><cmd>set nohidden<cr>',
        desc = 'diffview: close all buffers',
      },
    },
    opts = {
      default_args = { DiffviewFileHistory = { '%' } },
      enhanced_diff_hl = true,
      hooks = {
        diff_buf_read = function()
          local opt = vim.opt_local
          opt.wrap, opt.list, opt.relativenumber = false, false, false
          opt.colorcolumn = ''
        end,
      },
      keymaps = {
        view = { q = '<Cmd>DiffviewClose<CR>' },
        file_panel = { q = '<Cmd>DiffviewClose<CR>' },
        file_history_panel = { q = '<Cmd>DiffviewClose<CR>' },
      },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    cond = not rvim.plugins.minimal,
    event = { 'BufRead', 'BufNewFile' },
    opts = {
      signs = {
        add = { highlight = 'GitSignsAdd', text = left_block },
        change = { highlight = 'GitSignsChange', text = left_block },
        delete = {
          highlight = 'GitSignsDelete',
          text = icons.misc.triangle_short,
        },
        topdelete = { highlight = 'GitSignsChangeDelete', text = left_block },
        changedelete = { highlight = 'GitSignsChange', text = left_block },
        untracked = { highlight = 'GitSignsAdd', text = left_block },
      },
      _threaded_diff = true,
      _extmark_signs = true,
      _signs_staged_enable = true,
      word_diff = false,
      numhl = false,
      ---@diagnostic disable-next-line: need-check-nil
      current_line_blame = not cwd:match('personal') and not cwd:match('dots'),
      current_line_blame_formatter = ' <author>, <author_time> · <summary>',
      preview_config = { border = border },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function bmap(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          map(mode, l, r, opts)
        end

        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage' })
        -- map('n', '<leader>hw', gs.toggle_word_diff, { desc = 'toggle word diff' })
        map(
          'n',
          '<leader>hd',
          gs.toggle_deleted,
          { desc = 'show deleted lines' }
        )
        map(
          'n',
          '<leader>hp',
          gs.preview_hunk_inline,
          { desc = 'preview hunk' }
        )
        map(
          'n',
          '<leader>hb',
          gs.toggle_current_line_blame,
          { desc = 'toggle line blame' }
        )

        map('n', '<leader>gbl', gs.blame_line, { desc = 'blame line' })
        map(
          'n',
          '<leader>gr',
          gs.reset_buffer,
          { desc = 'reset entire buffer' }
        )
        map(
          'n',
          '<leader>gw',
          gs.stage_buffer,
          { desc = 'stage entire buffer' }
        )
        map(
          'n',
          '<leader>gl',
          function() gs.setqflist('all') end,
          { desc = 'list modified in qf' }
        )
        bmap(
          { 'n', 'v' },
          '<leader>hs',
          '<Cmd>Gitsigns stage_hunk<CR>',
          { desc = 'stage hunk' }
        )
        bmap(
          { 'n', 'v' },
          '<leader>hr',
          '<Cmd>Gitsigns reset_hunk<CR>',
          { desc = 'reset hunk' }
        )
        bmap(
          { 'o', 'x' },
          'ih',
          ':<C-U>Gitsigns select_hunk<CR>',
          { desc = 'select hunk' }
        )

        map('n', '[h', function()
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = 'next hunk' })

        map('n', ']h', function()
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = 'previous hunk' })

        map(
          'n',
          '<leader>hx',
          '<Cmd>Gitsigns refresh<CR>',
          { desc = 'refresh' }
        )
      end,
    },
  },
  {
    'almo7aya/openingh.nvim',
    cond = not rvim.plugins.minimal,
    keys = {
      {
        '<leader>gof',
        function()
          vim.cmd('OpenInGHFile')
          vim.notify('opening file in github', 'info', { title = 'openingh' })
        end,
        desc = 'openingh: open file',
      },
      {
        '<leader>gor',
        function()
          vim.cmd('OpenInGHRepo')
          vim.notify('opening repo in github', 'info', { title = 'openingh' })
        end,
        desc = 'openingh: open repo',
      },
      {
        '<leader>gol',
        function()
          vim.cmd('OpenInGHFileLines')
          vim.notify(
            'opening file line in github',
            'info',
            { title = 'openingh' }
          )
        end,
        desc = 'openingh: open to line',
        mode = { 'n', 'x' },
      },
    },
  },
  {
    '9seconds/repolink.nvim',
    cmd = { 'RepoLink' },
    keys = {
      {
        '<leader>gog',
        '<Cmd>RepoLink<CR>',
        desc = 'repolink: generate link',
        mode = { 'n', 'x' },
      },
    },
    opts = {},
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  {
    'yutkat/git-rebase-auto-diff.nvim',
    ft = { 'gitrebase' },
    opts = {},
  },
  {
    'emmanueltouzery/agitator.nvim',
    cond = not rvim.plugins.minimal,
    keys = {
      {
        '<leader>gbo',
        "<cmd>lua require'agitator'.git_blame_toggle()<cr>",
        desc = 'agitator: toggle blame',
      },
    },
  },
  {
    'akinsho/git-conflict.nvim',
    cond = not rvim.plugins.minimal,
    event = 'VeryLazy',
    opts = { disable_diagnostics = true },
    config = function(_, opts)
      rvim.highlight.plugin('git-conflict', {
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
  {
    '2kabhishek/co-author.nvim',
    cond = not rvim.plugins.minimal,
    cmd = 'GitCoAuthors',
    dependencies = { 'stevearc/dressing.nvim' },
  },
  {
    'niuiic/git-log.nvim',
    cond = not rvim.plugins.minimal,
    keys = {
      {
        '<leader>gL',
        "<Cmd>lua require'git-log'.check_log()<CR>",
        mode = { 'n', 'x' },
        desc = 'git-log: show log',
      },
    },
    dependencies = { 'niuiic/core.nvim' },
  },
}
