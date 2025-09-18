vim.cmd.runtime({ 'ftplugin/typescript.lua', bang = true })

local api = vim.api

local function toggle_use_client()
  local first_line = api.nvim_buf_get_lines(0, 0, 1, false)[1]
  if string.match(first_line, 'use client') then
    api.nvim_buf_set_lines(0, 0, 1, false, {})
  else
    api.nvim_buf_set_lines(0, 0, 1, false, { '"use client";' })
  end
end

map(
  'n',
  '<localleader>lu',
  toggle_use_client,
  { buffer = 0, desc = 'toggle use client' }
)
