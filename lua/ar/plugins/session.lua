return {
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
    -- stylua: ignore
    keys = {
      { '<leader>qs', function() require('persistence').load() end, desc = 'restore session' },
      { '<leader>ql', function() require('persistence').load({ last = true }) end, desc = 'restore last session' },
      { '<leader>qL', function() require('persistence').select() end,desc = 'select session' },
      { '<leader>qd', function() require('persistence').stop() end, desc = "don't save current session" },
    },
  },
  {
    'olimorris/persisted.nvim',
    cond = false,
    init = function() ar.command('ListSessions', 'Telescope persisted') end,
    cmd = { 'SessionLoad', 'SessionLoadLast', 'ListSessions', 'SessionStop' },
    -- stylua: ignore
    keys = {
      { '<leader>qs', ':SessionLoad<CR>', desc = 'restore session', silent = true },
      { '<leader>ql', ':SessionLoadLast<CR>', desc = 'restore last session', silent = true },
      { '<leader>qL', ':ListSessions<CR>', desc = 'list session', silent = true },
      { '<leader>qd', ':SessionStop<CR>', desc = "don't save current session", silent = true },
    },
    opts = {
      use_git_branch = true,
      save_dir = vim.fn.expand(vim.fn.stdpath('cache') .. '/sessions/'),
      on_autoload_no_session = function() vim.cmd.Alpha() end,
      should_save = function() return vim.bo.filetype ~= 'alpha' end,
    },
  },
}
