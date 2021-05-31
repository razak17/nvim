-- local G = require 'core.global'
local M = {}

local fn = vim.fn
local fmt = string.format

-- Ref: https://github.com/akinsho/dotfiles/blob/main/.config/nvim/lua/as/tmux.lua
function M.on_enter()
  local session = fn.fnamemodify(vim.loop.cwd(), ":t") or "Neovim"
  local window_title = session
  -- local fname = fn.expand("%:t")
  -- if G.is_empty(fname) then
  --   return
  -- end
  window_title = fmt("%s", session)
  fn.jobstart(fmt("tmux rename-window '%s'", window_title))
end

function M.on_leave()
  fn.jobstart("tmux set-window-option automatic-rename on")
end

return M

