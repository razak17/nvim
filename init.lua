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

<<<<<<< HEAD
vim.cmd [[syntax off]]
vim.cmd [[filetype off]]

-- Load base config
if fn.filereadable(fn.fnamemodify("~/.vimrc.local", ":p")) > 0 then
  cmd [[source ~/.vimrc.local]]
end

-- Bootstrap
local home_dir = vim.loop.os_homedir()

vim.opt.rtp:append(home_dir .. "/.local/share/rvim/site")

vim.opt.rtp:remove(home_dir .. "/.config/nvim")
vim.opt.rtp:remove(home_dir .. "/.config/nvim/after")
vim.opt.rtp:append(home_dir .. "/.config/rvim")
vim.opt.rtp:append(home_dir .. "/.config/rvim/after")

vim.opt.rtp:remove(home_dir .. "/.local/share/nvim/site")
vim.opt.rtp:remove(home_dir .. "/.local/share/nvim/site/after")
vim.opt.rtp:append(home_dir .. "/.local/share/rvim/site")
vim.opt.rtp:append(home_dir .. "/.local/share/rvim/site/after")

vim.cmd [[let &packpath = &runtimepath]]

-- Load Modules
require "core"
=======
if not vim.tbl_contains(vim.opt.rtp:get(), base_dir) then vim.opt.rtp:append(base_dir) end

vim.api.nvim_create_augroup('vimrc', {}) -- Ensure all autocommands are cleared

local ok, reload = pcall(require, 'plenary.reload')
RELOAD = ok and reload.reload_module or function(...) return ... end
function R(name)
  RELOAD(name)
  return require(name)
end

----------------------------------------------------------------------------------------------------
-- Global namespace
----------------------------------------------------------------------------------------------------
local namespace = {
  -- for UI elements like the winbar and statusline that need global references
  ui = {},
  -- some vim mappings require a mixture of commandline commands and function calls
  -- this table is place to store lua functions to be called in those mappings
  mappings = {},
}

_G.rvim = rvim or namespace

----------------------------------------------------------------------------------------------------
-- Load Modules
----------------------------------------------------------------------------------------------------
R('user.globals')
R('user.bootstrap')
R('user.config')
>>>>>>> origin/dual
