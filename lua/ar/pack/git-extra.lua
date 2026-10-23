local git_cond = require('ar.utils.git').git_cond

ar.pack.add({
  {
    src = 'https://github.com/niuiic/git-log.nvim',
    cond = function() return git_cond('git-log.nvim') end,
    -- stylua: ignore
    keys = {
      { mode = { 'n', 'x' }, '<leader>gL', "<Cmd>lua require'git-log'.check_log()<CR>", desc = 'git-log: show line/selection log' },
    },
    dependencies = { { src = 'https://github.com/niuiic/omega.nvim' } },
  },
  {
    src = 'https://github.com/Salanoid/gitlogdiff.nvim',
    cond = function() return git_cond('gitlogdiff.nvim') end,
    cmd = { 'GitLogDiff' },
    -- stylua: ignore
    keys = {
      { '<localleader>gdL', '<Cmd>GitLogDiff<CR>', desc = 'gitlogdiff: log diff' },
    },
    setup = function() require('gitlogdiff').setup({ max_count = 10 }) end,
    dependencies = {
      require('ar.pack.git-diff'),
      { src = 'https://github.com/folke/snacks.nvim' },
    },
  },
  {
    src = 'https://codeberg.org/mauritz/gitstatus.nvim',
    cond = function() return git_cond('gitstatus.nvim') end,
    cmd = { 'Gitstatus' },
    keys = {
      { '<localleader>gg', vim.cmd.Gitstatus, desc = 'open commit buffer' },
    },
  },
  {
    src = 'https://github.com/kilavila/nvim-gitignore',
    cond = function()
      return ar.get_plugin_cond('nvim-gitignore', not ar.plugins.minimal)
    end,
    cmd = { 'Gitignore', 'Licenses' },
    init = function()
      ar.add_to_select('command_palette', {
        ['Generate Gitignore'] = 'Gitignore',
        ['Generate License'] = 'Licenses',
      })
    end,
  },
  {
    src = 'https://github.com/yutkat/git-rebase-auto-diff.nvim',
    cond = function() return git_cond('git-rebase-auto-diff.nvim') end,
    ft = { 'gitrebase' },
    setup = function() require('git-rebase-auto-diff').setup({}) end,
  },
  {
    src = 'https://github.com/aaronhallaert/advanced-git-search.nvim',
    cond = function()
      return git_cond('advanced-git-search.nvim')
        and ar.config.picker.variant == 'telescope'
    end,
    cmd = { 'AdvancedGitSearch' },
    init = function()
      ar.add_to_select('git', { ['Git Search'] = 'AdvancedGitSearch' })
    end,
    setup = function()
      require('ar.pack.telescope')
      require('telescope').load_extension('advanced_git_search')
    end,
    dependencies = {
      { src = 'https://github.com/tpope/vim-fugitive' },
      { src = 'https://github.com/tpope/vim-rhubarb' },
    },
  },
  {
    src = 'https://github.com/2kabhishek/co-author.nvim',
    cond = function() return git_cond('co-author.nvim') end,
    cmd = { 'CoAuthor' },
    init = function()
      ar.add_to_select('git', { ['List Authors'] = 'CoAuthor' })
    end,
  },
  {
    src = 'https://github.com/isakbm/gitgraph.nvim',
    cond = function() return git_cond('gitgraph.nvim') end,
    setup = function()
      require('gitgraph').setup({
        symbols = { merge_commit = 'M', commit = '*' },
        format = {
          timestamp = '%H:%M:%S %d-%m-%Y',
          fields = { 'hash', 'timestamp', 'author', 'branch_name', 'tag' },
        },
      })
    end,
    keys = function(load)
      map('n', '<leader>gG', function()
        load()
        require('gitgraph').draw({}, { all = true, max_count = 5000 })
      end, { desc = 'git graph: draw' })
    end,
  },
})
