local minimal = ar.plugins.minimal
local git_cond = require('ar.utils.git').git_cond

return {
  {
    'FabijanZulj/blame.nvim',
    cond = function() return git_cond('blame.nvim') end,
    cmd = { 'BlameToggle' },
    init = function()
      ar.add_to_select_menu('git', { ['Toggle Blame'] = 'BlameToggle' })
    end,
    config = function() require('blame').setup() end,
  },
  {
    'niuiic/git-log.nvim',
    cond = function() return git_cond('git-log.nvim') end,
    -- stylua: ignore
    keys = {
      { mode = { 'n', 'x' }, '<leader>gL', "<Cmd>lua require'git-log'.check_log()<CR>", desc = 'git-log: show line/selection log' },
    },
    dependencies = { 'niuiic/omega.nvim' },
  },
  {
    'rbong/vim-flog',
    cond = function() return git_cond('vim-flog') end,
    init = function()
      ar.add_to_select_menu('git', { ['View Branch Graph'] = 'Flog' })
    end,
    cmd = { 'Flog', 'Flogsplit', 'Floggit' },
    dependencies = { 'tpope/vim-fugitive', 'tpope/vim-rhubarb' },
  },
  {
    'SuperBo/fugit2.nvim',
    cond = function() return git_cond('fugit2.nvim') end,
    cmd = { 'Fugit2', 'Fugit2Blame', 'Fugit2Diff', 'Fugit2Graph' },
    opts = { width = 100 },
  },
  {
    'Mauritz8/gitstatus.nvim',
    cond = function() return git_cond('gitstatus.nvim') end,
    cmd = { 'Gitstatus' },
    keys = {
      { '<localleader>gg', vim.cmd.Gitstatus, desc = 'open commit buffer' },
    },
  },
  {
    'kilavila/nvim-gitignore',
    cond = function() return ar.get_plugin_cond('nvim-gitignore', not minimal) end,
    cmd = { 'Gitignore', 'Licenses' },
    init = function()
      ar.add_to_select_menu('command_palette', {
        ['Generate Gitignore'] = 'Gitignore',
        ['Generate License'] = 'Licenses',
      })
    end,
  },
  {
    'yutkat/git-rebase-auto-diff.nvim',
    cond = function() return git_cond('git-rebase-auto-diff.nvim') end,
    ft = { 'gitrebase' },
    opts = {},
  },
  {
    'ldelossa/gh.nvim',
    cond = function() return git_cond('gh.nvim') end,
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
  {
    'aaronhallaert/advanced-git-search.nvim',
    cond = function()
      return git_cond('advanced-git-search.nvim')
        and (not ar.plugin_disabled('telescope.nvim') and not minimal)
    end,
    cmd = { 'AdvancedGitSearch' },
    init = function()
      ar.add_to_select_menu('git', { ['Git Search'] = 'AdvancedGitSearch' })
    end,
    config = function()
      require('telescope').load_extension('advanced_git_search')
    end,
  },
  {
    '2kabhishek/co-author.nvim',
    cond = function() return git_cond('co-author.nvim') end,
    cmd = 'CoAuthor',
    init = function()
      ar.add_to_select_menu('git', { ['List Authors'] = 'CoAuthor' })
    end,
  },
  {
    'isakbm/gitgraph.nvim',
    cond = function() return git_cond('gitgraph.nvim') end,
    opts = {
      symbols = { merge_commit = 'M', commit = '*' },
      format = {
        timestamp = '%H:%M:%S %d-%m-%Y',
        fields = { 'hash', 'timestamp', 'author', 'branch_name', 'tag' },
      },
    },
    init = function()
      map(
        'n',
        '<leader>gG',
        function()
          require('gitgraph').draw({}, { all = true, max_count = 5000 })
        end,
        { desc = 'git graph: draw' }
      )
    end,
  },
}
