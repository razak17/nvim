if not rvim then return end

local g, fn = vim.g, vim.fn
local data = vim.fn.stdpath('data')

--------------------------------------------------------------------------------
-- Project local config
--------------------------------------------------------------------------------
local local_config = io.open(vim.fn.expand('%:p:h') .. '/.rvim.json', 'r')
if local_config then rvim.project_config(local_config) end
--------------------------------------------------------------------------------
-- Set leader keys
--------------------------------------------------------------------------------
-- NOTE: Leader keys have to be set before lazy is loaded
g.mapleader = ' '
g.maplocalleader = ','
--------------------------------------------------------------------------------
-- Set Providers
--------------------------------------------------------------------------------
vim.g.python3_host_prog = join_paths(data, 'venv', 'bin', 'python3')
for _, v in pairs({ 'python', 'ruby', 'perl' }) do
  g['loaded_' .. v .. '_provider'] = 0
end
--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------
require('ar.settings')
require('ar.highlights')
require('ar.ui')
--------------------------------------------------------------------------------
-- Plugins
--------------------------------------------------------------------------------
local lazy_path = join_paths(data, 'lazy', 'lazy.nvim')
local plugins_enabled = rvim.plugins.enable
if not vim.uv.fs_stat(lazy_path) then
  -- stylua: ignore
  fn.system({ 'git', 'clone', '--filter=blob:none', '--single-branch',
    'https://github.com/folke/lazy.nvim.git', lazy_path,
  })
end
vim.opt.rtp:prepend(lazy_path)
local plugins_path = fn.stdpath('config') .. '/lua/ar/plugins'
local plugins_list = vim.fs.find(function(name, _)
  local filename = name:match('(.+)%.lua$')
  return name:match('.*.lua$') and not rvim.module_disabled(filename)
end, { path = plugins_path, limit = math.huge, type = 'file' })
local spec = vim.iter(plugins_list):fold({}, function(acc, path)
  local _, pos = path:find(plugins_path)
  acc[#acc + 1] = { import = 'ar.plugins.' .. path:sub(pos + 2, #path - 4) }
  return acc
end)
require('lazy').setup({
  spec = plugins_enabled and spec or {},
  defaults = { lazy = true },
  change_detection = { notify = false },
  git = { timeout = 720 },
  dev = {
    path = join_paths(vim.g.projects_dir, 'plugins'),
    patterns = { 'razak17' },
    fallback = true,
  },
  ui = { border = rvim.ui.current.border },
  checker = {
    enabled = true,
    concurrency = 30,
    notify = true,
    frequency = 3600,
  },
  performance = {
    rtp = {
      paths = { join_paths(data, 'site'), join_paths(data, 'site', 'after') },
      disabled_plugins = plugins_enabled and rvim.rtp.disabled or {},
    },
  },
})
map('n', '<localleader>L', '<cmd>Lazy<CR>', { desc = 'toggle lazy ui' })
--------------------------------------------------------------------------------
-- Color Scheme
--------------------------------------------------------------------------------
if not plugins_enabled then rvim.load_colorscheme('habamax') end

if vim.g.neovide then require('ar.neovide') end
