return {
  {
    'olimorris/persisted.nvim',
    init = function() ar.command('ListSessions', 'Telescope persisted') end,
    cmd = { 'SessionLoad', 'SessionLoadLast', 'ListSessions', 'SessionStop' },
    keys = {
      { '<leader>qs', ':SessionLoad<CR>', desc = 'restore session' },
      { '<leader>ql', ':SessionLoadLast<CR>', desc = 'restore last session' },
      { '<leader>qL', ':ListSessions<CR>', desc = 'list session' },
      { '<leader>qd', ':SessionStop<CR>', desc = "don't save current session" },
    },
    opts = {
      use_git_branch = true,
      save_dir = vim.fn.expand(vim.fn.stdpath('cache') .. '/sessions/'),
      on_autoload_no_session = function() vim.cmd.Alpha() end,
      should_save = function() return vim.bo.filetype ~= 'alpha' end,
    },
  },
}
