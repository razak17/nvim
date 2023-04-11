----------------------------------------------------------------------------------------------------
--       ____   ____.__
-- ______\   \ /   /|__| _____
-- \_  __ \   Y   / |  |/     \       Razak Mo's neovim config
--  |  | \/\     /  |  |  Y Y  \      https://github.com/razak17
--  |__|    \___/   |__|__|_|  /
--                           \/
----------------------------------------------------------------------------------------------------
local g, fn, env = vim.g, vim.fn, vim.env

if vim.loader then vim.loader.enable() end

g.dotfiles = env.DOTFILES or fn.expand('~/.dots')
g.projects_dir = env.DEV_HOME or fn.expand('~/personal/workspace/coding')
----------------------------------------------------------------------------------------------------
-- Global namespace
----------------------------------------------------------------------------------------------------
local namespace = {
  debug = false,
  lsp = {
    signs = { enable = true },
    hover_diagnostics = { enable = true },
  },
  mappings = {},
  path = { mason = vim.fn.stdpath('data') .. '/mason' },
  plugins = { enable = true },
  ui = {
    tw = {},
    statuscolumn = { enable = true },
    winbar = { enable = true, relative_path = true, file_icon = true },
  },
}

_G.rvim = rvim or namespace
_G.map = vim.keymap.set
----------------------------------------------------------------------------------------------------
-- Load Modules
----------------------------------------------------------------------------------------------------
-- Order matters here as globals needs to be instantiated first etc.
require('user.globals')
require('user.bootstrap')
