local function get_cond(plugin, variant)
  local condition = ar.config.session.enable
    and ar.config.session.variant == variant
  return ar.get_plugin_cond(plugin, condition)
end

if get_cond('persisted.nvim', 'persisted') then
  local loaded = false

  local function load()
    if loaded then return end

    vim.pack.add(
      { 'https://github.com/olimorris/persisted.nvim' },
      { confirm = false }
    )

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
    loaded = true
  end

  ar.pack.cmd('Persisted', load)

  vim.api.nvim_create_autocmd({ 'BufReadPre' }, {
    once = true,
    callback = load,
  })

  map('n', '<leader>ql', function()
    load()
    vim.cmd('Persisted load')
  end, { desc = 'restore session', silent = true })
  map('n', '<leader>qL', function()
    load()
    vim.cmd('Persisted load_last')
  end, { desc = 'restore last session', silent = true })
  map('n', '<leader>qo', function()
    load()
    vim.cmd('Persisted select')
  end, { desc = 'list session', silent = true })
  map('n', '<leader>qd', function()
    load()
    vim.cmd('Persisted stop')
  end, { desc = "don't save current session", silent = true })
end
