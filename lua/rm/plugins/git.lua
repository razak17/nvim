local fmt = string.format
local cwd = fmt('%s', vim.fn.getcwd())
local icons = rvim.ui.icons
local border = rvim.ui.current.border
local left_block = icons.separators.left_block

local enabled = not rvim.plugins.minimal and rvim.is_git_repo()

return {
  { 'yutkat/git-rebase-auto-diff.nvim', ft = { 'gitrebase' }, opts = {} },
  {
    'NeogitOrg/neogit',
    cond = enabled,
    cmd = 'Neogit',
    branch = 'nightly',
    commit = '023a515fa33904e140f3f20a83e6fb1c7b9ffffe',
    dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' },
    -- stylua: ignore
    keys = {
      { '<localleader>gs', function() require('neogit').open() end, desc = 'open status buffer', },
      { '<localleader>gc', function() require('neogit').open({ 'commit' }) end, desc = 'open commit buffer', },
      { '<localleader>gl', function() require('neogit.popups.pull').create() end, desc = 'open pull popup', },
      { '<localleader>gp', function() require('neogit.popups.push').create({}) end, desc = 'open push popup', },
    },
    opts = {
      disable_signs = false,
      disable_hint = true,
      disable_commit_confirmation = true,
      disable_builtin_notifications = true,
      disable_insert_on_commit = false,
      disable_context_highlighting = true,
      signs = {
        section = { icons.misc.chevron_right, icons.misc.chevron_down }, -- "", "󰘕"
        item = { '▸', '▾' },
        hunk = { '樂', '' },
      },
      integrations = { diffview = true },
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
    'chrisgrieser/nvim-tinygit',
    cond = enabled,
    -- stylua: ignore
    keys = {
      { '<leader>ga', '<Cmd>lua require("tinygit").amendOnlyMsg()<CR>', desc = 'amend commit' },
      -- { '<leader>gc', '<Cmd>lua require("tinygit").smartCommit()<CR>', desc = 'smart commit' },
      -- { '<leader>gp', '<Cmd>lua require("tinygit").push()<CR>', desc = 'smart push' },
      { '<leader>gg', '<Cmd>lua require("tinygit").createGitHubPr()<CR>', desc = 'create pr' },
      { '<leader>gii', '<Cmd>lua require("tinygit").issuesAndPrs()<CR>', desc = 'issues and prs' },
      { '<leader>gio', '<Cmd>lua require("tinygit").openIssueUnderCursor()<CR>', desc = 'open issue under cursor' },
      { '<leader>gsP', '<Cmd>lua require("tinygit").stashPush()<CR>', desc = 'stash push' },
      { '<leader>gsp', '<Cmd>lua require("tinygit").stashPop()<CR>', desc = 'stash pop' },
    },
    ft = { 'gitrebase', 'gitcommit' },
    dependencies = { 'stevearc/dressing.nvim', 'rcarriga/nvim-notify' },
  },
  {
    'sindrets/diffview.nvim',
    cond = enabled,
    cmd = {
      'DiffviewOpen',
      'DiffviewFileHistory',
      'DiffviewToggleFiles',
      'DiffviewFocusFiles',
    },
    -- stylua: ignore
    keys = {
      { '<localleader>gd', '<Cmd>DiffviewOpen<CR>', desc = 'diffview: open' },
      { 'gh', [[:'<'>DiffviewFileHistory<CR>]], desc = 'diffview: file history', mode = 'v', },
      { '<localleader>gh', '<Cmd>DiffviewFileHistory<CR>', desc = 'diffview: file history', },
      { '<localleader>gx', '<cmd>set hidden<cr><cmd>DiffviewClose<cr><cmd>set nohidden<cr>', desc = 'diffview: close all buffers', },
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
    cond = enabled,
    event = { 'BufRead', 'BufNewFile' },
    opts = {
      signs = {
        add = { highlight = 'GitSignsAdd', text = left_block },
        change = { highlight = 'GitSignsChange', text = left_block },
        delete = {
          highlight = 'GitSignsDelete',
          text = icons.misc.separator,
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
      current_line_blame = not cwd:match('personal') and not cwd:match('dots'),
      current_line_blame_formatter = ' <author>, <author_time> · <summary>',
      preview_config = { border = border },
      -- stylua: ignore
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function bmap(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          map(mode, l, r, opts)
        end

        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage' })
        -- map('n', '<leader>hw', gs.toggle_word_diff, { desc = 'toggle word diff' })
        map('n', '<leader>hd', gs.toggle_deleted, { desc = 'show deleted lines' })
        map('n', '<leader>hp', gs.preview_hunk_inline, { desc = 'preview hunk inline' })
        map('n', '<leader>hb', gs.toggle_current_line_blame, { desc = 'toggle line blame' })

        map('n', '<leader>gbl', gs.blame_line, { desc = 'blame line' })
        map('n', '<leader>gr', gs.reset_buffer, { desc = 'reset entire buffer' })
        map('n', '<leader>gw', gs.stage_buffer, { desc = 'stage entire buffer' })
        map('n', '<leader>gq', function() gs.setqflist('all') end, { desc = 'list modified in qflist' })
        map('n', '<leader>gl', function() gs.setloclist() end, { desc = 'list modified in localist' })
        bmap({ 'n', 'v' }, '<leader>hs', '<Cmd>Gitsigns stage_hunk<CR>', { desc = 'stage hunk' })
        bmap({ 'n', 'v' }, '<leader>hr', '<Cmd>Gitsigns reset_hunk<CR>', { desc = 'reset hunk' })
        bmap({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select hunk' })

        map('n', '[h', function()
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = 'next hunk' })

        map('n', ']h', function()
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = 'previous hunk' })

        map('n', '<leader>hx', '<Cmd>Gitsigns refresh<CR>', { desc = 'refresh' })
      end,
    },
  },
  {
    'almo7aya/openingh.nvim',
    cond = enabled,
    cmd = { 'OpenInGHFile', 'OpenInGHRepo', 'OpenInGHFileLines' },
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
    'linrongbin16/gitlinker.nvim',
    config = function()
      require('gitlinker').setup({
        router = {
          default_branch = {
            ['^github%.com'] = 'https://github.com/'
              .. '{_A.USER}/'
              .. '{_A.REPO}/blob/'
              .. '{_A.DEFAULT_BRANCH}/' -- always 'master'/'main' branch
              .. '{_A.FILE}?plain=1' -- '?plain=1'
              .. '#L{_A.LSTART}'
              .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
          },
          current_branch = {
            ['^github%.com'] = 'https://github.com/'
              .. '{_A.USER}/'
              .. '{_A.REPO}/blob/'
              .. '{_A.CURRENT_BRANCH}/' -- always current branch
              .. '{_A.FILE}?plain=1' -- '?plain=1'
              .. '#L{_A.LSTART}'
              .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
          },
          blame_default_branch = {
            ['^github%.com'] = 'https://github.com/'
              .. '{_A.USER}/'
              .. '{_A.REPO}/blame/'
              .. '{_A.DEFAULT_BRANCH}/'
              .. '{_A.FILE}?plain=1' -- '?plain=1'
              .. '#L{_A.LSTART}'
              .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
          },
        },
      })
    end,
    keys = {
      {
        '<leader>gom',
        '<cmd>GitLink default_branch<cr>',
        desc = 'gitlinker: copy line URL (main branch)',
        mode = { 'n', 'v' },
      },
      {
        '<leader>gob',
        '<cmd>GitLink current_branch<cr>',
        desc = 'gitlinker: copy line URL (current branch)',
        mode = { 'n', 'v' },
      },
      {
        '<leader>goc',
        '<cmd>GitLink<cr>',
        desc = 'gitlinker: copy line URL (commit)',
        mode = { 'n', 'v' },
      },
      {
        '<leader>gbm',
        '<cmd>GitLink! blame_default_branch<cr>',
        desc = 'gitlinker: github blame (main branch)',
        mode = { 'v', 'n' },
      },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  {
    'emmanueltouzery/agitator.nvim',
    cond = enabled,
    keys = {
      {
        '<leader>gbo',
        "<Cmd>lua require'agitator'.git_blame_toggle()<CR>",
        desc = 'agitator: toggle blame',
      },
    },
  },
  {
    'dlvhdr/gh-blame.nvim',
    cond = enabled and false,
    -- stylua: ignore
    keys = {
      { '<leader>gbp', '<Cmd>GhBlameCurrentLine<CR>', desc = 'blame current line (PR)' },
    },
    dependencies = { 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim' },
  },
  {
    'FabijanZulj/blame.nvim',
    cmd = { 'BlameToggle' },
    config = function() require('blame').setup() end,
  },
  {
    'dlvhdr/gh-addressed.nvim',
    cmd = 'GhReviewComments',
    -- stylua: ignore
    keys = {
      { '<leader>gc', '<Cmd>GhReviewComments<CR>', desc = 'github review comments' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'folke/trouble.nvim',
    },
  },
  {
    'aaronhallaert/advanced-git-search.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'tpope/vim-fugitive',
      'tpope/vim-rhubarb',
      'sindrets/diffview.nvim',
    },
  },
  {
    'akinsho/git-conflict.nvim',
    cond = enabled,
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
    cond = enabled,
    cmd = 'CoAuthor',
    dependencies = { 'stevearc/dressing.nvim' },
  },
  {
    'niuiic/git-log.nvim',
    cond = enabled,
    -- stylua: ignore
    keys = {
      { '<leader>gL', "<Cmd>lua require'git-log'.check_log()<CR>", mode = { 'n', 'x' }, desc = 'git-log: show log', },
    },
    dependencies = { 'niuiic/core.nvim' },
  },
  {
    'rbong/vim-flog',
    cond = enabled,
    cmd = { 'Flog', 'Flogsplit', 'Floggit' },
    dependencies = { 'tpope/vim-fugitive' },
  },
  {
    'ldelossa/gh.nvim',
    cond = enabled,
    -- stylua: ignore
    cmd = {
      'GHCloseCommit', 'GHExpandCommit', 'GHOpenToCommit', 'GHPopOutCommit',
      'GHCollapseCommit', 'GHPreviewIssue', 'LTPanel', 'GHStartReview',
      'GHCloseReview', 'GHDeleteReview', 'GHExpandReview', 'GHSubmitReview',
      'GHCollapseReview', 'GHClosePR', 'GHPRDetails', 'GHExpandPR', 'GHOpenPR',
      'GHPopOutPR', 'GHRefreshPR', 'GHOpenToPR', 'GHCollapsePR', 'GHCreateThread',
      'GHNextThread', 'GHToggleThread',
    },
    dependencies = {
      {
        'ldelossa/litee.nvim',
        config = function() require('litee.lib').setup() end,
      },
    },
    config = function() require('litee.gh').setup() end,
  },
}
