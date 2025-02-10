local enabled = ar_config.plugin.custom.sticky_yank.enable

if not ar or ar.none or not enabled then return end

local api, v = vim.api, vim.v

-- https://github.com/ruicsh/nvim-config/blob/4b09396a06ed46145252803dfdc7a33fdd8a4bd7/plugin/autocmds/yank-keep-cursor-position.lua#L1
local cursor_pre_yank

local function store_cursor_position()
  cursor_pre_yank = api.nvim_win_get_cursor(0)
end

map({ 'n', 'x' }, 'y', function()
  store_cursor_position()
  return 'y'
end, { expr = true, silent = true, unique = true })

-- don't include whitespaces at the end
map('n', 'Y', function()
  store_cursor_position()
  return 'yg_'
end, { expr = true, silent = true })

map(
  'n',
  '<localleader>Y',
  -- ':%y+<CR>',
  function()
    store_cursor_position()
    vim.cmd('%y+')
  end,
  { desc = 'yank all' }
)

-- Keep cursor position on yank.
ar.augroup('StickyYank', {
  event = { 'TextYankPost' },
  command = function()
    if v.event.operator == 'y' and cursor_pre_yank then
      -- Get buffer line count
      local line_count = api.nvim_buf_line_count(0)
      -- Check if cursor position is valid
      if cursor_pre_yank[1] <= line_count then
        local line_length = #api.nvim_buf_get_lines(
          0,
          cursor_pre_yank[1] - 1,
          cursor_pre_yank[1],
          true
        )[1]
        if cursor_pre_yank[2] <= line_length then
          api.nvim_win_set_cursor(0, cursor_pre_yank)
        end
      end
    end
  end,
})
