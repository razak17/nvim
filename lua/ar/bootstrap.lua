if not ar or ar.none then return end

local g = vim.g
local data = vim.fn.stdpath('data')

--------------------------------------------------------------------------------
-- Project local config
--------------------------------------------------------------------------------
local local_config = io.open(vim.fn.expand('%:p:h') .. '/.rvim.json', 'r')
if local_config then ar.project_config(ar.config, local_config) end
--------------------------------------------------------------------------------
-- Set leader keys
--------------------------------------------------------------------------------
-- NOTE: Leader keys have to be set before lazy is loaded
g.mapleader = ' '
g.maplocalleader = ','
--------------------------------------------------------------------------------
-- Set Providers
--------------------------------------------------------------------------------
vim.g.python3_host_prog = vim.fs.joinpath(data, 'venv', 'bin', 'python3')
for _, v in pairs({ 'python', 'ruby', 'perl' }) do
  g['loaded_' .. v .. '_provider'] = 0
end
for _, v in pairs({ 'netrw', 'netrwPlugin' }) do
  g['loaded_' .. v] = 1
end
--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------
require('ar.settings')
require('ar.highlights')
require('ar.ui')
--------------------------------------------------------------------------------
-- Neovide
--------------------------------------------------------------------------------
if vim.g.neovide then require('ar.neovide') end
--------------------------------------------------------------------------------
-- Plugins
--------------------------------------------------------------------------------
if ar.plugins.enable then
  if ar.package_manager == 'lazy' then require('ar.lazy') end
  if ar.package_manager == 'vim.pack' then
    require('ar.core.pack')
    require('ar.pack')
  end
end
--------------------------------------------------------------------------------
-- Features
--------------------------------------------------------------------------------
require('ar.core')
require('ar.extras')
