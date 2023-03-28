if not rvim then return end

local g, fn, env, rtp = vim.g, vim.fn, vim.env, vim.opt.rtp

g.dotfiles = env.DOTFILES or fn.expand('~/.dots')
g.projects_dir = env.DEV_HOME or fn.expand('~/projects')
----------------------------------------------------------------------------------------------------
-- Ensure all autocommands are cleared
vim.api.nvim_create_augroup('vimrc', {})
----------------------------------------------------------------------------------------------------
-- Set leader keys
----------------------------------------------------------------------------------------------------
-- NOTE: Leader keys have to be set before lazy is loaded
g.mapleader = ' '
g.maplocalleader = ','
----------------------------------------------------------------------------------------------------
-- Set Providers
----------------------------------------------------------------------------------------------------
g.python3_host_prog = join_paths(vim.call('stdpath', 'cache'), 'venv', 'neovim', 'bin', 'python3')
for _, v in pairs({ 'python', 'ruby', 'perl' }) do
  g['loaded_' .. v .. '_provider'] = 0
end
----------------------------------------------------------------------------------------------------
-- Set Open Command
----------------------------------------------------------------------------------------------------
g.os = vim.loop.os_uname().sysname
rvim.open_command = g.os == 'Darwin' and 'open' or 'xdg-open'
----------------------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------------------
require('user.settings')
require('user.highlights')
require('user.ui')
----------------------------------------------------------------------------------------------------
-- Plugins
----------------------------------------------------------------------------------------------------
local data = fn.stdpath('data')
local lazy_path = join_paths(data, 'lazy', 'lazy.nvim')
if not vim.loop.fs_stat(lazy_path) then
    -- stylua: ignore
    vim.fn.system({
      'git', 'clone', '--filter=blob:none', '--single-branch', 'https://github.com/folke/lazy.nvim.git',
      lazy_path,
    })
end
rtp:prepend(lazy_path)
local opts = {
  defaults = { lazy = true },
  change_detection = { notify = false },
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
      paths = { join_paths(data, 'site'), join_paths(data, 'site', 'after') },
        -- stylua: ignore
        disabled_plugins = {
          '2html_plugin', 'gzip', 'matchit', 'rrhelper', 'netrw', 'netrwPlugin', 'netrwSettings',
          'netrwFileHandlers', 'zip', 'zipPlugin', 'tar', 'tarPlugin', 'getscript', 'getscriptPlugin',
          'vimball', 'vimballPlugin', 'logipat', 'spellfile_plugin',
        },
    },
  },
}
require('lazy').setup('user.plugins', opts)
map('n', '<localleader>L', '<cmd>Lazy<CR>', { desc = 'lazygit: toggle ui' })
----------------------------------------------------------------------------------------------------
-- Color Scheme
----------------------------------------------------------------------------------------------------
if not rvim.plugins.enable then return end
rvim.wrap_err('theme failed to load because', vim.cmd.colorscheme, 'onedark')
