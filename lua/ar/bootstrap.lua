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
vim.g.python3_host_prog = join_paths(data, 'venv', 'bin', 'python3')
-- if g.node_host_prog == nil and g.loaded_node_provider ~= 0 and vim.fn.executable('pnpm') == 1 then
--   -- pnpm 11 stores global packages in isolated directories that Nvim cannot detect.
--   local ok, result = pcall(function()
--     return vim.system({ 'pnpm', 'list', '-g', '--json' }, { text = true }):wait(2000)
--   end)
--   if ok and result.code == 0 then
--     local decoded, installs = pcall(vim.json.decode, result.stdout)
--     if decoded and type(installs) == 'table' then
--       for _, install in ipairs(installs) do
--         local deps = type(install) == 'table' and install.dependencies
--         local host = type(deps) == 'table' and deps.neovim
--         if type(host) == 'table' and type(host.path) == 'string' then
--           local entry = join_paths(host.path, 'bin', 'cli.js')
--           if vim.fn.filereadable(entry) == 1 then
--             g.node_host_prog = entry
--             break
--           end
--         end
--       end
--     end
--   end
-- end
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
if not ar.plugins.enable then return end
if ar.package_manager == 'lazy' then require('ar.lazy') end
if ar.package_manager == 'vim.pack' then require('ar.pack') end
require('ar.core')
require('ar.extras')
