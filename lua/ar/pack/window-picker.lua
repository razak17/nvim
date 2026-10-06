if not ar.get_plugin_cond('nvim-window-picker') then return end

local api = vim.api

local loaded = false
local function load()
  if loaded then return end
  vim.pack.add({
    {
      src = 'https://github.com/s1n7ax/nvim-window-picker',
      version = vim.version.range('2.*'),
    },
  }, { confirm = false })

  local picker = require('window-picker')
  picker.setup({
    hint = 'floating-big-letter',
    show_prompt = false,
    selection_chars = 'HJKLUIOPNMYTGBVCREWQSZAFD',
    filter_rules = {
      autoselect_one = true,
      include_current_win = false,
      include_unfocusable_windows = false,
      buftype = { 'terminal', 'quickfix', 'nofile' },
    -- stylua: ignore
    bo = {
      filetype = {
        'neo-tree-popup', 'snacks_picker_input', 'snacks_picker_list',
        'NvimTree', 'neo-tree', 'notify', 'snacks_notif',
      },
      buftype = {
        'terminal', 'nofile', 'quickfix', 'help', 'prompt', 'notify', 'float',
      },
    },
    },
  })
  loaded = true
end

map('n', '<leader>wp', function()
  load()
  local picker = require('window-picker')
  local window = picker.pick_window({ include_current_win = true })
  if window then api.nvim_set_current_win(window) end
end, { desc = 'pick window' })

map('n', '<leader>ws', function()
  load()
  local picker = require('window-picker')
  local window = picker.pick_window({ include_current_win = false })
  if not window then return end
  local target_buffer = vim.fn.winbufnr(window)
  api.nvim_win_set_buf(window, 0)
  if target_buffer ~= 0 then api.nvim_win_set_buf(0, target_buffer) end
end, { desc = 'swap window' })
