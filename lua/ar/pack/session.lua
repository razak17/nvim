local function get_cond(plugin, variant)
  local condition = ar.config.session.enable
    and ar.config.session.variant == variant
  return ar.get_plugin_cond(plugin, condition)
end

ar.pack.add({
  src = 'https://github.com/olimorris/persisted.nvim',
  cond = function() return get_cond('persisted.nvim', 'persisted') end,
  cmd = { 'Persisted' },
  event = 'BufReadPre',
  -- stylua: ignore
  keys = {
    { '<leader>ql', '<Cmd>Persisted load<CR>', desc = 'restore session' },
    { '<leader>qL', '<Cmd>Persisted load_last<CR>', desc = 'restore last session' },
    { '<leader>qo', '<Cmd>Persisted select<CR>', desc = 'list session' },
    { '<leader>qd', '<Cmd>Persisted stop<CR>', desc = "don't save current session" },
  },
  setup = function()
    local opts = {
      follow_cwd = true, -- Change the session file to match any change in the cwd?
      use_git_branch = true,
      save_dir = vim.fn.expand(vim.fn.stdpath('cache') .. '/sessions/'),
      on_autoload_no_session = function() vim.cmd.Alpha() end,
      should_save = function()
        return not vim.tbl_contains({ 'alpha', 'cheatsheet' }, vim.bo.ft)
          and not vim.tbl_contains({ 'nofile' }, vim.bo.bt)
      end,
    }

    require('persisted').setup(opts)
  end,
})
