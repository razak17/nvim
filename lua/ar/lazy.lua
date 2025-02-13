local api, fn = vim.api, vim.fn
local data = fn.stdpath('data')

local lazy_path = join_paths(data, 'lazy', 'lazy.nvim')
local plugins_enabled = ar.plugins.enable
if not vim.uv.fs_stat(lazy_path) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  -- stylua: ignore start
  local out = fn.system({ 'git', 'clone', '--filter=blob:none', '--single-branch', lazyrepo, lazy_path })
  -- stylua: ignore end
  if vim.v.shell_error ~= 0 then
    api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazy_path)
require('lazy').setup({
  spec = { { import = 'ar.plugins' } },
  defaults = { lazy = true },
  change_detection = { notify = false },
  git = { timeout = 720 },
  --- @type table
  dev = {
    path = join_paths(vim.g.projects_dir, 'plugins'),
    patterns = { 'razak17' },
    fallback = true,
  },
  -- ui = { border = ar.ui.current.border },
  checker = {
    enabled = true,
    concurrency = 30,
    notify = false,
    frequency = 3600,
  },
  performance = {
    rtp = {
      paths = { join_paths(data, 'site'), join_paths(data, 'site', 'after') },
      disabled_plugins = plugins_enabled and ar.rtp.disabled or {},
    },
  },
})
map('n', '<localleader>L', '<cmd>Lazy<CR>', { desc = 'toggle lazy ui' })
