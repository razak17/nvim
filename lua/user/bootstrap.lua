if not rvim then return end

local g, fn, env, rtp = vim.g, vim.fn, vim.env, vim.opt.rtp

g.dotfiles = env.DOTFILES or fn.expand('~/.dots')
g.projects_dir = env.DEV_HOME or fn.expand('~/projects')
----------------------------------------------------------------------------------------------------
-- Set leader keys
----------------------------------------------------------------------------------------------------
-- NOTE: Leader keys have to be set before lazy is loaded
g.mapleader = ' '
g.maplocalleader = ','
----------------------------------------------------------------------------------------------------
-- Set Providers
----------------------------------------------------------------------------------------------------
g.python3_host_prog = join_paths(rvim.get_cache_dir(), 'venv', 'neovim', 'bin', 'python3')
for _, v in pairs({ 'python', 'ruby', 'perl' }) do
  g['loaded_' .. v .. '_provider'] = 0
end
----------------------------------------------------------------------------------------------------
-- Set Open Command
----------------------------------------------------------------------------------------------------
g.os = vim.loop.os_uname().sysname
rvim.open_command = g.os == 'Darwin' and 'open' or 'xdg-open'
----------------------------------------------------------------------------------------------------
-- Append RTP
----------------------------------------------------------------------------------------------------
rtp:remove(join_paths(vim.call('stdpath', 'data'), 'site'))
rtp:remove(join_paths(vim.call('stdpath', 'data'), 'site', 'after'))
rtp:prepend(join_paths(rvim.get_runtime_dir(), 'site', 'after'))
rtp:append(join_paths(rvim.get_runtime_dir(), 'site', 'pack', 'lazy'))

rtp:remove(vim.call('stdpath', 'config'))
rtp:remove(join_paths(vim.call('stdpath', 'config'), 'after'))
rtp:prepend(rvim.get_config_dir())
rtp:append(join_paths(rvim.get_config_dir(), 'after'))

vim.cmd([[let &packpath = &runtimepath]])
----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------
require('user.settings')
require('user.highlights')
require('user.ui')
----------------------------------------------------------------------------------------------------
-- Plugins
----------------------------------------------------------------------------------------------------
local lazy_path = join_paths(rvim.get_runtime_dir(), 'site', 'pack', 'lazy', 'lazy.nvim')
if not vim.loop.fs_stat(lazy_path) then
    -- stylua: ignore
    vim.fn.system({
      'git', 'clone', '--filter=blob:none', '--single-branch', 'https://github.com/folke/lazy.nvim.git',
      lazy_path,
    })
end
vim.opt.rtp:prepend(lazy_path)
local opts = {
  root = join_paths(rvim.get_runtime_dir(), 'site', 'pack', 'lazy'),
  defaults = { lazy = true },
  lockfile = join_paths(rvim.get_config_dir(), 'lazy-lock.json'),
  git = { timeout = 720 },
  dev = {
    path = join_paths(vim.env.HOME, 'personal', 'workspace', 'coding', 'plugins'),
    patterns = { 'razak17' },
    fallback = true,
  },
  ui = { border = rvim.ui.current.border },
  checker = { enabled = true, concurrency = 30, notify = false, frequency = 3600 },
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
    cache = { path = join_paths(rvim.get_cache_dir(), 'lazy', 'cache') },
  },
  readme = { root = join_paths(rvim.get_cache_dir(), 'lazy', 'readme') },
}
require('lazy').setup('user.plugins', opts)
map('n', '<localleader>L', '<cmd>Lazy<CR>', { desc = 'lazygit: toggle ui' })
----------------------------------------------------------------------------------------------------
-- Color Scheme
----------------------------------------------------------------------------------------------------
if not rvim.plugins.enable then return end
rvim.wrap_err('theme failed to load because', vim.cmd.colorscheme, 'onedark')
