local function get_cond(plugin, variant)
  return function()
    local condition = ar.config.session.enable
      and ar.config.session.variant == variant
    return ar.get_plugin_cond(plugin, condition)
  end
end

return {
  {
    'folke/persistence.nvim',
    cond = get_cond('persistence.nvim', 'persistence'),
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
      cond = get_cond('persisted.nvim', 'persisted'),
      event = 'BufReadPre',
      cmd = { 'SessionLoad', 'SessionLoadLast', 'SessionSelect', 'SessionStop' },
      init = function()
        ar.augroup('PersistedEvents', {
          event = { 'User' },
          pattern = 'PersistedTelescopeLoadPre',
          command = function()
            vim.schedule(function() vim.cmd('%bd') end)
          end,
        }, {
          event = { 'User' },
          pattern = 'PersistedSavePre',
          -- Arguments are always persisted in a session and can't be removed using 'sessionoptions'
          -- so remove them when saving a session
          command = function() vim.cmd('%argdelete') end,
        })
      end,
      -- stylua: ignore
      keys = {
        { '<leader>ql', '<Cmd>Persisted load<CR>', desc = 'restore session', silent = true },
        { '<leader>qL', '<Cmd>Persisted load_last<CR>', desc = 'restore last session', silent = true },
        { '<leader>qo', '<Cmd>Persisted select<CR>', desc = 'list session', silent = true },
        { '<leader>qd', '<Cmd>Persisted stop<CR>', desc = "don't save current session", silent = true },
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
        return get_cond('persisted.nvim', 'persisted')()
            and vim.g.telescope_add_extension({ 'persisted' }, opts, {
              persisted = ar.telescope.dropdown(),
            })
          or opts
      end,
    },
  },
}
