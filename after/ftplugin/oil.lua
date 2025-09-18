if not ar or ar.none then return end

local api, opt = vim.api, vim.opt

opt.conceallevel = 3
opt.concealcursor = 'n'
opt.list = false
opt.wrap = false
opt.signcolumn = 'no'

if not ar.has('oil.nvim') then return end

local oil = require('oil')
local function find_files()
  local dir = oil.get_current_dir()
  if api.nvim_win_get_config(0).relative ~= '' then
    api.nvim_win_close(0, true)
  end
  ar.pick('files', { cwd = dir })()
end

local function livegrep()
  local dir = oil.get_current_dir()
  if api.nvim_win_get_config(0).relative ~= '' then
    api.nvim_win_close(0, true)
  end
  ar.pick('live_grep', { cwd = dir })()
end

map('n', '<leader>ff', find_files, { desc = 'find [F]iles in dir', buffer = 0 })
map('n', '<leader>fs', livegrep, { desc = 'find by [G]rep in dir', buffer = 0 })

api.nvim_buf_create_user_command(
  0,
  'Save',
  function(params) oil.save({ confirm = not params.bang }) end,
  {
    desc = 'Save oil changes with a preview',
    bang = true,
  }
)
api.nvim_buf_create_user_command(
  0,
  'EmptyTrash',
  function(params) oil.empty_trash() end,
  { desc = 'Empty the trash directory' }
)
api.nvim_buf_create_user_command(
  0,
  'OpenTerminal',
  function(params) require('oil.adapters.ssh').open_terminal() end,
  { desc = 'Open the debug terminal for ssh connections' }
)
