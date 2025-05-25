--------------------------------------------------------------------------------
--       ____   ____.__
-- ______\   \ /   /|__| _____
-- \_  __ \   Y   / |  |/     \       Razak Mo's neovim config
--  |  | \/\     /  |  |  Y Y  \      https://github.com/razak17
--  |__|    \___/   |__|__|_|  /
--                           \/
--------------------------------------------------------------------------------
if vim.g.vscode then return end -- if using vscode

local g, fn, env = vim.g, vim.fn, vim.env

if vim.loader then vim.loader.enable() end

g.os = vim.uv.os_uname().sysname
g.dotfiles = env.DOTFILES or fn.expand('~/.dots')
g.projects_dir = env.DEV_HOME or fn.expand('~/personal/workspace/coding')
-- HACK: Hot patch for issue in Neovim v0.10.3 where vim.hl is not defined
if vim.fn.has('nvim-0.10.3') == 1 and not vim.hl then vim.hl = vim.highlight end
-- if fn.has('nvim-0.12') == 1 then require('vim._extui').enable({}) end
--------------------------------------------------------------------------------
-- Load Modules
--------------------------------------------------------------------------------
-- Order matters here as config and globals need to be instantiated first etc.
require('ar.config')
require('ar.globals')
require('ar.bootstrap')
