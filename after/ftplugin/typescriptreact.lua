vim.cmd.runtime({ 'ftplugin/typescript.lua', bang = true })

local api = vim.api

local function toggle_use_client()
  local first_line = api.nvim_buf_get_lines(0, 0, 1, false)[1]
  if first_line and string.match(first_line, 'use client') then
    -- Remove the 'use client' line
    api.nvim_buf_set_lines(0, 0, 1, false, {})
  elseif first_line and first_line ~= '' then
    -- Insert 'use client' at the top, keep the existing first line
    api.nvim_buf_set_lines(0, 0, 0, false, { '"use client"' })
  else
    -- Buffer is empty, just add 'use client'
    api.nvim_buf_set_lines(0, 0, 1, false, { '"use client"' })
  end
end

map(
  'n',
  '<localleader>lu',
  toggle_use_client,
  { buffer = 0, desc = 'toggle use client' }
)

-- https://github.com/emmanueltouzery/nvim_config/commit/dd12dad78f7663d7851cd26adea93808acc18995
-- https://github.com/nvim-mini/mini.nvim/discussions/2079

if not ar.has('mini.surround') then return end

-- Set specific surrounding in 'mini.surround'
local ts_input = require('mini.surround').gen_spec.input.treesitter
vim.b.minisurround_config = {
  custom_surroundings = {
    t = {
      input = ts_input({ outer = '@tag.outer', inner = '@tag.inner' }),
    },
    T = {
      input = ts_input({ outer = '@tag_name.outer', inner = '@tag_name.inner' }),
      output = function()
        local tag_name = MiniSurround.user_input('Tag name')
        return { left = tag_name, right = tag_name }
      end,
    },
  },
}
