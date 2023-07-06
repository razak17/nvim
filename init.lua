----------------------------------------------------------------------------------------------------
--       ____   ____.__
-- ______\   \ /   /|__| _____
-- \_  __ \   Y   / |  |/     \       Razak Mo's neovim config
--  |  | \/\     /  |  |  Y Y  \      https://github.com/razak17
--  |__|    \___/   |__|__|_|  /
--                           \/
----------------------------------------------------------------------------------------------------
if vim.g.vscode then return end -- if using vscode

local g, fn, env = vim.g, vim.fn, vim.env

if vim.loader then vim.loader.enable() end

g.dotfiles = env.DOTFILES or fn.expand('~/.dots')
g.projects_dir = env.DEV_HOME or fn.expand('~/personal/workspace/coding')
----------------------------------------------------------------------------------------------------
-- Global namespace
----------------------------------------------------------------------------------------------------
local namespace = {
  ai = { enable = env.RVIM_AI_ENABLED == '1' },
  debug = { enable = false },
  autosave = { enable = true },
  lsp = {
    enable = env.RVIM_LSP_ENABLED == '1' and env.RVIM_PLUGINS_MINIMAL == '0',
    disabled = {
      servers = { 'emmet_ls' },
      filetypes = {},
    },
    format_on_save = { enable = true },
    signs = { enable = false },
    hover_diagnostics = { enable = true },
  },
  mappings = {},
  minimal = env.RVIM_LSP_ENABLED == '0' or env.RVIM_PLUGINS_ENABLED == '0' or env.RVIM_NONE == '1',
  none = env.RVIM_NONE == '1',
  plugins = {
    enable = env.RVIM_PLUGINS_ENABLED == '1',
    disabled = {},
    minimal = env.RVIM_PLUGINS_MINIMAL == '1',
  },
  treesitter = { enable = true },
  ui = {
    statuscolumn = { enable = true },
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
