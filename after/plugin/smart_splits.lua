local enabled = ar_config.plugin.custom.smart_splits.enable

if not ar or ar.none or not enabled then return end

local api, fn = vim.api, vim.fn

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
-- @see: https://github.com/theopn/theovim/blob/main/lua/config/keymap.lua#L100
local function count_windows_in_direction(direction)
  local current_tabpage = api.nvim_get_current_tabpage()
  local windows = api.nvim_tabpage_list_wins(current_tabpage)
  local current_win = api.nvim_get_current_win()
  local current_pos = api.nvim_win_get_position(current_win)

  local count = 0
  for _, win in ipairs(windows) do
    if win ~= current_win then
      local pos = api.nvim_win_get_position(win)
      if direction == 'horizontal' then
        if pos[1] == current_pos[1] then count = count + 1 end
      elseif direction == 'vertical' then
        if pos[2] == current_pos[2] then count = count + 1 end
      end
    end
  end

  return count + 1
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

  if curr_win == fn.winnr() then
    local should_create_split = true

    if key == 'h' or key == 'l' then
      local current_columns = count_windows_in_direction('horizontal')
      if current_columns >= config.max_columns then
        should_create_split = false
      end
    else
      local current_rows = count_windows_in_direction('vertical')
      if current_rows >= config.max_rows then should_create_split = false end
    end

    if should_create_split then
      if key == 'h' or key == 'l' then
        vim.cmd('wincmd v')
      else
        vim.cmd('wincmd s')
      end
      vim.cmd('wincmd ' .. key)
    end
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
