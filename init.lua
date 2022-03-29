--------------------------------------------------------------------------------
--       ____   ____.__
-- ______\   \ /   /|__| _____
-- \_  __ \   Y   / |  |/     \       Razak Mo's neovim config
--  |  | \/\     /  |  |  Y Y  \      https://github.com/razak17
--  |__|    \___/   |__|__|_|  /
--                           \/
--------------------------------------------------------------------------------
local init_path = debug.getinfo(1, "S").source:sub(2)
local base_dir = init_path:match("(.*[/\\])"):sub(1, -2)

if not vim.tbl_contains(vim.opt.rtp:get(), base_dir) then
  vim.opt.rtp:append(base_dir)
end

vim.g.did_load_filetypes = 0 -- deactivate vim based filetype detection

local ok, reload = pcall(require, "plenary.reload")
RELOAD = ok and reload.reload_module or function(...)
  return ...
end
function _G.R(name)
  RELOAD(name)
  return require(name)
end
R = _G.R

------------------------------------------------------------------------
-- Load Modules
------------------------------------------------------------------------
R "user.config.globals"
require("user.config.bootstrap"):init(base_dir)

local Log = require "user.core.log"
Log:debug "Starting rVim"

require("user.config"):load()
require("user.lsp").setup()
