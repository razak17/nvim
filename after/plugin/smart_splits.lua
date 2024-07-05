local enabled = ar.plugin.smart_splits.enable

if not ar or ar.none or not enabled then return end

local fn = vim.fn

--------------------------------------------------------------------------------
-- Smart Splits
--------------------------------------------------------------------------------
--[[ move_or_create_win()
-- Move to a window (one of hjkl) or create a split if a window does not exist in the direction
-- Vimscript translation of:
-- https://www.reddit.com/r/vim/comments/166a3ij/comment/jyivcnl/?utm_source=share&utm_medium=web2x&context=3
-- Usage: vim.keymap("n", "<C-h>", function() move_or_create_win("h") end, {})
--
-- @arg key: One of h, j, k, l, a direction to move or create a split
--]]
-- ref: https://github.com/theopn/theovim/blob/main/lua/core.lua#L207
local function move_or_create_win(key)
  local exclusions = {
    'alpha',
    'neo-tree',
    'lazy',
    'NeogitStatus',
    'oil',
    'gitcommit',
    'NeogitCommitMessage',
    'DiffviewFileHistory',
    'DiffviewFiles',
    'qf',
    'Trouble',
  }
  if ar.find_string(exclusions, vim.bo.ft) then
    vim.cmd('wincmd ' .. key)
    return
  end
  local curr_win = fn.winnr()
  vim.cmd('wincmd ' .. key) --> attempt to move

  if curr_win == fn.winnr() then --> didn't move, so create a split
    if key == 'h' or key == 'l' then
      vim.cmd('wincmd v')
    else
      vim.cmd('wincmd s')
    end
    vim.cmd('wincmd ' .. key)
  end
end

map('n', '<C-h>', function() move_or_create_win('h') end, {
  desc = '[h]: Move to window on the left or create a split',
})
map(
  'n',
  '<C-j>',
  function() move_or_create_win('j') end,
  { desc = '[j]: Move to window below or create a vertical split' }
)
map(
  'n',
  '<C-k>',
  function() move_or_create_win('k') end,
  { desc = '[k]: Move to window above or create a vertical split' }
)
map(
  'n',
  '<C-l>',
  function() move_or_create_win('l') end,
  { desc = '[l]: Move to window on the right or create a split' }
)
