local enabled = not ar.noplugin and ar.plugin.smart_splits.enable

if not ar or ar.none or not enabled then return end

local fn = vim.fn

ar.smart_splits = {
  exclusions = {
    'alpha',
    'DiffviewFileHistory',
    'DiffviewFiles',
    'gitcommit',
    'lazy',
    'neo-tree',
    'NeogitCommitMessage',
    'NeogitStatus',
    'oil',
    'qf',
    'starter',
    'startup',
    'trouble',
    'AvanteInput',
    'TelescopePrompt'
  },
}

--------------------------------------------------------------------------------
-- Smart Splits
--------------------------------------------------------------------------------
-- Move to a window (one of hjkl) or create a split if a window does not exist in the direction
-- @see: https://github.com/theopn/theovim/blob/main/lua/config/keymap.lua#L100
local function move_or_create_win(key)
  if ar.find_string(ar.smart_splits.exclusions, vim.bo.ft) then
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

local function create_map(direction, key, description)
    -- stylua: ignore
  map('n', key, function() move_or_create_win(direction) end, { desc = description })
end

create_map('h', '<C-h>', '[h]: Move to window on the left or create a split')
create_map('j', '<C-j>', '[j]: Move to window below or create a vertical split')
create_map('k', '<C-k>', '[k]: Move to window above or create a vertical split')
create_map('l', '<C-l>', '[l]: Move to window on the right or create a split')
