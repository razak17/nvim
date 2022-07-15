--------------------------------------------------------------------------------
--       ____   ____.__
-- ______\   \ /   /|__| _____
-- \_  __ \   Y   / |  |/     \       Razak Mo's neovim config
--  |  | \/\     /  |  |  Y Y  \      https://github.com/razak17
--  |__|    \___/   |__|__|_|  /
--                           \/
--------------------------------------------------------------------------------
local init_path = debug.getinfo(1, 'S').source:sub(2)
local base_dir = init_path:match('(.*[/\\])'):sub(1, -2)

if not vim.tbl_contains(vim.opt.rtp:get(), base_dir) then vim.opt.rtp:append(base_dir) end

vim.api.nvim_create_augroup('vimrc', {}) -- Ensure all autocommands are cleared

local ok, reload = pcall(require, 'plenary.reload')
RELOAD = ok and reload.reload_module or function(...) return ... end
function R(name)
  RELOAD(name)
  return require(name)
end

------------------------------------------------------------------------
-- Load Modules
------------------------------------------------------------------------
R('user.globals')
R('user.bootstrap')
R('user.config')
