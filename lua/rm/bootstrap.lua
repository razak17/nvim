if not rvim then return end

local g = vim.g
local data = vim.fn.stdpath('data')

----------------------------------------------------------------------------------------------------
-- Project local config
----------------------------------------------------------------------------------------------------
local file = io.open(vim.fn.expand('%:p:h') .. '/.rvim.json', 'r')
if file then rvim.project_config(file) end
----------------------------------------------------------------------------------------------------
-- Set leader keys
----------------------------------------------------------------------------------------------------
-- NOTE: Leader keys have to be set before lazy is loaded
g.mapleader = ' '
g.maplocalleader = ','
----------------------------------------------------------------------------------------------------
-- Set Open Command
----------------------------------------------------------------------------------------------------
g.os = vim.uv.os_uname().sysname
rvim.open_command = g.os == 'Darwin' and 'open' or 'xdg-open'
----------------------------------------------------------------------------------------------------
-- Set Providers
----------------------------------------------------------------------------------------------------
vim.g.python3_host_prog = join_paths(data, 'venv', 'bin', 'python3')
for _, v in pairs({ 'python', 'ruby', 'perl' }) do
  g['loaded_' .. v .. '_provider'] = 0
end
----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------
require('rm.settings')
require('rm.highlights')
require('rm.ui')
----------------------------------------------------------------------------------------------------
-- Plugins
----------------------------------------------------------------------------------------------------
local lazy_path = join_paths(data, 'lazy', 'lazy.nvim')
local plugins_enabled = rvim.plugins.enable
if not vim.uv.fs_stat(lazy_path) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--single-branch',
    'https://github.com/folke/lazy.nvim.git',
    lazy_path,
  })
end
vim.opt.rtp:prepend(lazy_path)
-- If opening from inside neovim terminal then do not load other plugins
-- if env.NVIM then return require('lazy').setup({ { 'willothy/flatten.nvim', opts = {} } }) end
local plugins
if plugins_enabled then
  plugins = 'rm.plugins'
else
  plugins = {}
end
require('lazy').setup(plugins, {
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
      disabled_plugins = plugins_enabled and {
        '2html_plugin',
        'gzip',
        'matchit',
        'rrhelper',
        'netrw',
        'netrwPlugin',
        'netrwSettings',
        'netrwFileHandlers',
        'zip',
        'zipPlugin',
        'tar',
        'tarPlugin',
        'getscript',
        'getscriptPlugin',
        'vimball',
        'vimballPlugin',
        'logipat',
        'spellfile_plugin',
      } or {},
    },
  },
})
map('n', '<localleader>L', '<cmd>Lazy<CR>', { desc = 'toggle lazy ui' })
----------------------------------------------------------------------------------------------------
-- Color Scheme
----------------------------------------------------------------------------------------------------
if not plugins_enabled then rvim.load_colorscheme('habamax') end
if plugins_enabled then rvim.load_colorscheme('onedark') end
