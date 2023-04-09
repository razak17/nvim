if not rvim then return end

local g, env = vim.g, vim.env
local data = vim.call('stdpath', 'data')
----------------------------------------------------------------------------------------------------
-- Set leader keys
----------------------------------------------------------------------------------------------------
-- NOTE: Leader keys have to be set before lazy is loaded
g.mapleader = ' '
g.maplocalleader = ','
----------------------------------------------------------------------------------------------------
-- Set Open Command
----------------------------------------------------------------------------------------------------
g.os = vim.loop.os_uname().sysname
rvim.open_command = g.os == 'Darwin' and 'open' or 'xdg-open'
----------------------------------------------------------------------------------------------------
-- Set Providers
----------------------------------------------------------------------------------------------------
g.python3_host_prog = join_paths(vim.call('stdpath', 'cache'), 'venv', 'neovim', 'bin', 'python3')
for _, v in pairs({ 'python', 'ruby', 'perl' }) do
  g['loaded_' .. v .. '_provider'] = 0
end
----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------
require('user.settings')
require('user.highlights')
require('user.ui')
----------------------------------------------------------------------------------------------------
-- Plugins
----------------------------------------------------------------------------------------------------
local lazy_path = join_paths(data, 'lazy', 'lazy.nvim')
if not vim.loop.fs_stat(lazy_path) then
    -- stylua: ignore
    vim.fn.system({
      'git', 'clone', '--filter=blob:none', '--single-branch', 'https://github.com/folke/lazy.nvim.git',
      lazy_path,
    })
end
vim.opt.rtp:prepend(lazy_path)
-- If opening from inside neovim terminal then do not load other plugins
if env.NVIM then return require('lazy').setup({ { 'willothy/flatten.nvim', config = true } }) end
require('lazy').setup('user.plugins', {
  defaults = { lazy = true },
  change_detection = { notify = false },
  git = { timeout = 720 },
  dev = {
    path = join_paths(vim.g.projects_dir, 'plugins'),
    patterns = { 'razak17' },
    fallback = true,
  },
  ui = { border = rvim.ui.current.border },
  checker = { enabled = true, concurrency = 30, notify = false, frequency = 3600 },
  performance = {
    rtp = {
      paths = { join_paths(data, 'site'), join_paths(data, 'site', 'after') },
        -- stylua: ignore
        disabled_plugins = {
          '2html_plugin', 'gzip', 'matchit', 'rrhelper', 'netrw', 'netrwPlugin', 'netrwSettings',
          'netrwFileHandlers', 'zip', 'zipPlugin', 'tar', 'tarPlugin', 'getscript', 'getscriptPlugin',
          'vimball', 'vimballPlugin', 'logipat', 'spellfile_plugin',
        },
    },
  },
})
map('n', '<localleader>L', '<cmd>Lazy<CR>', { desc = 'toggle lazy ui' })
----------------------------------------------------------------------------------------------------
-- Color Scheme
----------------------------------------------------------------------------------------------------
if not rvim.plugins.enable then return end
rvim.pcall('theme failed to load because', vim.cmd.colorscheme, 'onedark')
