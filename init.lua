----------------------------------------------------------------------------------------------------
--       ____   ____.__
-- ______\   \ /   /|__| _____
-- \_  __ \   Y   / |  |/     \       Razak Mo's neovim config
--  |  | \/\     /  |  |  Y Y  \      https://github.com/razak17
--  |__|    \___/   |__|__|_|  /
--                           \/
----------------------------------------------------------------------------------------------------
local init_path = debug.getinfo(1, 'S').source:sub(2)
local base_dir = init_path:match('(.*[/\\])'):sub(1, -2)

if not vim.tbl_contains(vim.opt.rtp:get(), base_dir) then vim.opt.rtp:append(base_dir) end
----------------------------------------------------------------------------------------------------
-- Ensure all autocommands are cleared
vim.api.nvim_create_augroup('vimrc', {})
----------------------------------------------------------------------------------------------------
local ok, reload = pcall(require, 'plenary.reload')
RELOAD = ok and reload.reload_module or function(...) return ... end
function R(name)
  RELOAD(name)
  return require(name)
end

local uv = vim.loop
function join_paths(...)
  local path_sep = uv.os_uname().version:match('Windows') and '\\' or '/'
  return table.concat({ ... }, path_sep)
end
----------------------------------------------------------------------------------------------------
-- Global namespace
----------------------------------------------------------------------------------------------------
local namespace = {
  -- some vim mappings require a mixture of commandline commands and function calls
  -- this table is place to store lua functions to be called in those mappings
  mappings = {},
  auto_save = false,
  lsp = {
    signs = { enable = true },
    hover_diagnostics = { enable = true },
  },
  path = { mason = join_paths(vim.call('stdpath', 'data'), 'mason') },
  plugins = { enable = true },
  ui = {
    tw = {},
    winbar = { enable = true, use_relative_path = true, use_file_icon = true },
  },
}

_G.rvim = rvim or namespace
_G.map = vim.keymap.set
----------------------------------------------------------------------------------------------------
-- Load Modules
----------------------------------------------------------------------------------------------------
R('user.globals')
R('user.bootstrap')

----------------------------------------------------------------------------------------------------
-- Color Scheme
----------------------------------------------------------------------------------------------------
if not rvim.plugins.enable then return end
rvim.wrap_err('theme failed to load because', vim.cmd.colorscheme, 'zephyr')
