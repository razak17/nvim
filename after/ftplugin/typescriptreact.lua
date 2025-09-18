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
