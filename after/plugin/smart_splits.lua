local enabled = ar.config.plugin.custom.smart_splits.enable

if not ar or ar.none or not enabled then return end

local fn = vim.fn

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
    if key == 'h' or key == 'l' then
      vim.cmd('wincmd v')
    else
      vim.cmd('wincmd s')
    end

    vim.cmd('wincmd ' .. key) --> move again
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
