local fn = vim.fn

local Lazy = {}
Lazy.__index = Lazy

function Lazy:load_plugins()
  local plugins_dir = join_paths(rvim.get_config_dir(), 'lua', 'user', 'plugins')

  self.repos = {}

  local list = {}
  local tmp = vim.split(fn.globpath(plugins_dir, '**/*.lua'), '\n')
  for _, f in ipairs(tmp) do
    list[#list + 1] = string.match(f, 'lua/(.+).lua$')
  end

  if not rvim.plugins.enable then return end

  for _, m in ipairs(list) do
    self.repos[#self.repos + 1] = require(m)
  end
end

function Lazy:bootstrap()
  local lazy_path = join_paths(rvim.get_runtime_dir(), 'site', 'pack', 'lazy', 'lazy.nvim')
  if not vim.loop.fs_stat(lazy_path) then
    -- stylua: ignore
    vim.fn.system({
      'git', 'clone', '--filter=blob:none', '--single-branch', 'https://github.com/folke/lazy.nvim.git',
      lazy_path,
    })
  end
  vim.opt.rtp:prepend(lazy_path)
  self:load_plugins()
  local opts = {
    root = join_paths(rvim.get_runtime_dir(), 'site', 'pack', 'lazy'),
    defaults = { lazy = true },
    lockfile = join_paths(rvim.get_config_dir(), 'lazy-lock.json'),
    git = { timeout = 720 },
    dev = {
      path = join_paths(vim.env.HOME, 'personal', 'workspace', 'coding', 'plugins'),
      patterns = { 'razak17' },
    },
    ui = { border = rvim.ui.current.border },
    checker = {
      enabled = true,
      concurrency = 30,
      notify = false,
      frequency = 3600, -- check for updates every hour
    },
    performance = {
      rtp = {
        reset = false,
        paths = { join_paths(rvim.get_runtime_dir(), 'site') },
        -- stylua: ignore
        disabled_plugins = {
          '2html_plugin', 'gzip', 'matchit', 'rrhelper', 'netrw', 'netrwPlugin', 'netrwSettings',
          'netrwFileHandlers', 'zip', 'zipPlugin', 'tar', 'tarPlugin', 'getscript', 'getscriptPlugin',
          'vimball', 'vimballPlugin', 'logipat', 'spellfile_plugin',
        },
      },
      enabled = true,
      cache = { path = join_paths(rvim.get_cache_dir(), 'lazy', 'cache') },
    },
    readme = { root = join_paths(rvim.get_cache_dir(), 'lazy', 'readme') },
  }
  require('lazy').setup(self.repos, opts)
  map('n', '<localleader>L', '<cmd>Lazy<CR>', { desc = 'lazygit: toggle ui' })
end

return Lazy
