if not ar then return end

local enabled = ar.config.plugin.extra.smart_splits.enable

if ar.none or not enabled then return end

local fn, api = vim.fn, vim.api

local config = {
  max_columns = 3,
  max_rows = 3,
  excluded = {
    filetypes = {
      'alpha',
      'Avante',
      'AvanteInput',
      'AvanteSelectedFiles',
      'copilot-chat',
      'DiffviewFileHistory',
      'DiffviewFiles',
      'fyler',
      'gitcommit',
      'help',
      'lazy',
      'neo-tree',
      'NeogitCommitMessage',
      'NeogitStatus',
      'oil',
      'qf',
      'starter',
      'startup',
      'trouble',
      'tsplayground',
      'TelescopePrompt',
      'noice',
      'snacks_dashboard',
      'vscode-diff-explorer',
      'codecompanion',
      'kulala_ui',
    },
    buftypes = {
      -- 'nofile',
      'nowrite',
      'quickfix',
      'prompt',
      'terminal',
    },
  },
}

--------------------------------------------------------------------------------
-- Smart Splits
--------------------------------------------------------------------------------
-- Move to a window (one of hjkl) or create a split if a window does not exist in the direction
-- @see: https://github.com/theopn/dotfiles/blob/0901eb3ac67700225b44d1025513e843621a991f/nvim/.config/nvim/lua/theovim/keymaps.lua#L123
local function count_windows_on_line(axis)
  local current_win = api.nvim_get_current_win()
  local current_position = api.nvim_win_get_position(current_win)
  local current_size = axis == 'row' and api.nvim_win_get_height(current_win)
    or api.nvim_win_get_width(current_win)
  local position_index = axis == 'row' and 1 or 2
  local center = current_position[position_index]
    + math.floor((current_size - 1) / 2)
  local count = 0

  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    if api.nvim_win_get_config(win).relative == '' then
      local position = api.nvim_win_get_position(win)
      local size = axis == 'row' and api.nvim_win_get_height(win)
        or api.nvim_win_get_width(win)
      local first_cell = position[position_index]
      local cell_after_separator = first_cell + size + 1

      if center >= first_cell and center < cell_after_separator then
        count = count + 1
      end
    end
  end

  return count
end

local function split_limit_reached(key)
  local creates_column = key == 'h' or key == 'l'
  local limit = creates_column and config.max_columns or config.max_rows

  if type(limit) ~= 'number' or limit <= 0 then return false end

  local axis = creates_column and 'row' or 'column'
  return count_windows_on_line(axis) >= limit
end

local function move_or_create_win(key)
  local is_excluded_bt = vim.tbl_contains(config.excluded.buftypes, vim.bo.bt)
  local is_excluded_ft = vim.tbl_contains(config.excluded.filetypes, vim.bo.ft)
  if is_excluded_bt or is_excluded_ft then
    vim.cmd('wincmd ' .. key)
    return
  end
  local curr_win = fn.winnr()
  vim.cmd('wincmd ' .. key)

  if curr_win == fn.winnr() then --> didn't move, so create a split
    if split_limit_reached(key) then return end

    if key == 'h' or key == 'l' then
      vim.cmd('wincmd v')
    else
      vim.cmd('wincmd s')
    end

    vim.cmd('wincmd ' .. key) --> move again
  end
end

local function create_map(direction, key, desc)
  map('n', key, function() move_or_create_win(direction) end, { desc = desc })
end

create_map('h', '<C-h>', '[h]: Move to window on the left or create a split')
create_map('j', '<C-j>', '[j]: Move to window below or create a vertical split')
create_map('k', '<C-k>', '[k]: Move to window above or create a vertical split')
create_map('l', '<C-l>', '[l]: Move to window on the right or create a split')
