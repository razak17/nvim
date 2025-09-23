local function get_cond(plugin)
  return function()
    return ar_config.session.enable and ar_config.session.variant == plugin
  end
end

return {
  {
    'folke/persistence.nvim',
    cond = get_cond('persistence'),
    event = 'BufReadPre',
    opts = {},
    -- stylua: ignore
    keys = {
      { '<leader>ql', function() require('persistence').load() end, desc = 'restore session' },
      { '<leader>qL', function() require('persistence').load({ last = true }) end, desc = 'restore last session' },
      { '<leader>qo', function() require('persistence').select() end,desc = 'select session' },
      { '<leader>qd', function() require('persistence').stop() end, desc = "don't save current session" },
    },
  },
  {
    {
      'olimorris/persisted.nvim',
      cond = get_cond('persisted'),
      event = 'BufReadPre',
      cmd = { 'SessionLoad', 'SessionLoadLast', 'SessionSelect', 'SessionStop' },
    -- stylua: ignore
    keys = {
      { '<leader>ql', ':SessionLoad<CR>', desc = 'restore session', silent = true },
      { '<leader>qL', ':SessionLoadLast<CR>', desc = 'restore last session', silent = true },
      { '<leader>qo', ':SessionSelect<CR>', desc = 'list session', silent = true },
      { '<leader>qd', ':SessionStop<CR>', desc = "don't save current session", silent = true },
    },
      opts = {
        follow_cwd = true, -- Change the session file to match any change in the cwd?
        use_git_branch = true,
        save_dir = vim.fn.expand(vim.fn.stdpath('cache') .. '/sessions/'),
        on_autoload_no_session = function() vim.cmd.Alpha() end,
        should_save = function()
          return not vim.tbl_contains({ 'alpha', 'cheatsheet' }, vim.bo.ft)
            and not vim.tbl_contains({ 'nofile' }, vim.bo.bt)
        end,
      },
    },
    {
      'nvim-telescope/telescope.nvim',
      optional = true,
      opts = function(_, opts)
        return get_cond('persisted')
            and vim.g.telescope_add_extension({ 'persisted' }, opts, {
              persisted = ar.telescope.dropdown(),
            })
          or opts
      end,
    },
  },
}
