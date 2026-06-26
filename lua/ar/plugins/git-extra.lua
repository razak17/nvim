local minimal = ar.plugins.minimal
local git_cond = require('ar.utils.git').git_cond

return {
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
    'Salanoid/gitlogdiff.nvim',
    main = 'gitlogdiff',
    cond = function() return git_cond('gitlogdiff.nvim') end,
    cmd = 'GitLogDiff',
    -- stylua: ignore
    keys = {
      { '<localleader>gdL', '<Cmd>GitLogDiff<CR>', desc = 'gitlogdiff: log diff' },
    },
    opts = { max_count = 10 },
    dependencies = { 'sindrets/diffview.nvim', 'folke/snacks.nvim' },
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
      ar.add_to_select('command_palette', {
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
    'aaronhallaert/advanced-git-search.nvim',
    cond = function()
      return git_cond('advanced-git-search.nvim')
        and ar.config.picker.variant == 'telescope'
    end,
    cmd = { 'AdvancedGitSearch' },
    init = function()
      ar.add_to_select('git', { ['Git Search'] = 'AdvancedGitSearch' })
    end,
    config = function()
      require('telescope').load_extension('advanced_git_search')
    end,
    dependencies = { 'tpope/vim-fugitive', 'tpope/vim-rhubarb' },
  },
  {
    '2kabhishek/co-author.nvim',
    cond = function() return git_cond('co-author.nvim') end,
    cmd = 'CoAuthor',
    init = function()
      ar.add_to_select('git', { ['List Authors'] = 'CoAuthor' })
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
