----------------------------------------------------------------------------------------------------
--       ____   ____.__
-- ______\   \ /   /|__| _____
-- \_  __ \   Y   / |  |/     \       Razak Mo's neovim config
--  |  | \/\     /  |  |  Y Y  \      https://github.com/razak17
--  |__|    \___/   |__|__|_|  /
--                           \/
----------------------------------------------------------------------------------------------------
-- Global namespace
----------------------------------------------------------------------------------------------------
local namespace = {
  -- some vim mappings require a mixture of commandline commands and function calls
  -- this table is place to store lua functions to be called in those mappings
  mappings = {},
  autosave = true,
  plugins = { enable = true },
  path = { mason = vim.call('stdpath', 'data') .. '/mason' },
  lsp = {
    signs = { enable = true },
    hover_diagnostics = { enable = true },
  },
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
