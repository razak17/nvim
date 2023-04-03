local cwd = vim.fn.getcwd()
local highlight = rvim.highlight
local icons = rvim.ui.icons.separators

local function neogit() return require('neogit') end

return {
  {
    'TimUntersberger/neogit',
    cmd = 'Neogit',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<localleader>gs', function() neogit().open() end, desc = 'open status buffer' },
      { '<localleader>gc', function() neogit().open({ 'commit' }) end, desc = 'open commit buffer' },
      { '<localleader>gl', function() neogit().popups.pull.create() end, desc = 'open pull popup' },
      { '<localleader>gp', function() neogit().popups.push.create() end, desc = 'open push popup' },
    },
    opts = {
      disable_signs = false,
      disable_hint = true,
      disable_commit_confirmation = true,
      disable_builtin_notifications = true,
      disable_insert_on_commit = false,
      signs = {
        section = { '', '' }, -- "", ""
        item = { '▸', '▾' },
        hunk = { '樂', '' },
      },
      integrations = {
        diffview = true,
      },
    },
    config = function(_, opts)
      require('neogit').setup(opts)
      highlight.plugin('neogit', { -- NOTE: highlights must be set AFTER neogit's setup
        { NeogitDiffAdd = { link = 'DiffAdd' } },
        { NeogitDiffDelete = { link = 'DiffDelete' } },
        { NeogitDiffAddHighlight = { link = 'DiffAdd' } },
        { NeogitDiffDeleteHighlight = { link = 'DiffDelete' } },
        { NeogitDiffContextHighlight = { link = 'NormalFloat' } },
        { NeogitHunkHeader = { link = 'TabLine' } },
        { NeogitHunkHeaderHighlight = { link = 'DiffText' } },
      })
    end,
  },
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
    keys = {
      { '<localleader>gd', '<Cmd>DiffviewOpen<CR>', desc = 'diffview: open' },
      { 'gh', [[:'<'>DiffviewFileHistory<CR>]], desc = 'diffview: file history', mode = 'v' },
      { '<localleader>gh', '<Cmd>DiffviewFileHistory<CR>', desc = 'diffview: file history' },
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
    config = function(_, opts)
      rvim.highlight.plugin('diffview', {
        { DiffAddedChar = { bg = 'NONE', fg = { from = 'DiffAdd', attr = 'bg', alter = 0.3 } } },
        { DiffChangedChar = { bg = 'NONE', fg = { from = 'DiffChange', attr = 'bg', alter = 0.3 } } },
        { DiffviewStatusAdded = { link = 'DiffAddedChar' } },
        { DiffviewStatusModified = { link = 'DiffChangedChar' } },
        { DiffviewStatusRenamed = { link = 'DiffChangedChar' } },
        { DiffviewStatusUnmerged = { link = 'DiffChangedChar' } },
        { DiffviewStatusUntracked = { link = 'DiffAddedChar' } },
      })
      require('diffview').setup(opts)
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { highlight = 'GitSignsAdd', text = icons.right_block },
        change = { highlight = 'GitSignsChange', text = icons.right_block },
        delete = { highlight = 'GitSignsDelete', text = icons.right_block },
        topdelete = { highlight = 'GitSignsChangeDelete', text = icons.right_block },
        changedelete = { highlight = 'GitSignsChange', text = icons.right_block },
        untracked = { highlight = 'GitSignsAdd', text = icons.right_block },
      },
      _threaded_diff = true,
      _extmark_signs = true,
      _signs_staged_enable = true,
      word_diff = false,
      numhl = false,
      current_line_blame = not cwd:match('personal') and not cwd:match('dots'),
      current_line_blame_formatter = ' <author>, <author_time> · <summary>',
      preview_config = { border = rvim.ui.current.border },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function bmap(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          map(mode, l, r, opts)
        end

        map('n', '<leader>hs', gs.stage_hunk, { desc = 'stage hunk' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage' })
        map('n', '<leader>hw', gs.toggle_word_diff, { desc = 'toggle word diff' })
        map('n', '<leader>hd', gs.toggle_deleted, { desc = 'show deleted lines' })
        map('n', '<leader>hp', gs.preview_hunk_inline, { desc = 'preview hunk' })

        map('n', '<leader>gb', gs.blame_line, { desc = 'blame current line' })
        map('n', '<leader>gr', gs.reset_buffer, { desc = 'reset entire buffer' })
        map('n', '<leader>gw', gs.stage_buffer, { desc = 'stage entire buffer' })

        map('n', '<leader>gl', function() gs.setqflist('all') end, { desc = 'list modified in quickfix' })
        bmap({ 'n', 'v' }, '<leader>hs', '<Cmd>Gitsigns stage_hunk<CR>', { desc = 'stage hunk' })
        bmap({ 'n', 'v' }, '<leader>hr', '<Cmd>Gitsigns reset_hunk<CR>', { desc = 'reset hunk' })
        bmap({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select hunk' })

        map('n', '<leader>hj', function()
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = 'next hunk' })

        map('n', '<leader>hk', function()
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = 'previous hunk' })
      end,
    },
  },
}
