local opt = vim.opt

opt.conceallevel = 3
opt.concealcursor = 'n'
opt.list = false
opt.wrap = false
opt.signcolumn = 'no'

if not rvim.is_available('oil.nvim') then return end

local oil = require('oil')
local function find_files()
  local dir = oil.get_current_dir()
  if vim.api.nvim_win_get_config(0).relative ~= '' then
    vim.api.nvim_win_close(0, true)
  end
  require('fzf-lua').files({ cwd = dir, hidden = true })
end

local function livegrep()
  local dir = oil.get_current_dir()
  if vim.api.nvim_win_get_config(0).relative ~= '' then
    vim.api.nvim_win_close(0, true)
  end
  require('telescope.builtin').live_grep({ cwd = dir })
end
map('n', '<leader>ff', find_files, { desc = '[F]ind [F]iles in dir' })
map('n', '<leader>fg', livegrep, { desc = '[F]ind by [G]rep in dir' })
vim.api.nvim_buf_create_user_command(
  0,
  'Save',
  function(params) oil.save({ confirm = not params.bang }) end,
  {
    desc = 'Save oil changes with a preview',
    bang = true,
  }
)
vim.api.nvim_buf_create_user_command(
  0,
  'EmptyTrash',
  function(params) oil.empty_trash() end,
  { desc = 'Empty the trash directory' }
)
vim.api.nvim_buf_create_user_command(
  0,
  'OpenTerminal',
  function(params) require('oil.adapters.ssh').open_terminal() end,
  { desc = 'Open the debug terminal for ssh connections' }
)
