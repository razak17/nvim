local enabled = ar.config.plugin.custom.modify_line_end_delimiter.enable

if not ar or ar.none or not enabled then return end

local api = vim.api

-- TLDR: Conditionally modify character at end of line (add, remove or modify)
---@param character string
---@return function
local function modify_line_end_delimiter(character)
  local delimiters = { ',', ';' }
  return function()
    if not vim.bo.modifiable then return end
    local line = api.nvim_get_current_line()
    local last_char = line:sub(-1)
    if last_char == character then
      api.nvim_set_current_line(line:sub(1, #line - 1))
      return
    end
    if vim.tbl_contains(delimiters, last_char) then
      api.nvim_set_current_line(line:sub(1, #line - 1) .. character)
      return
    end
    api.nvim_set_current_line(line .. character)
  end
end

map(
  'n',
  '<localleader>,',
  modify_line_end_delimiter(','),
  { desc = 'append comma' }
)
map(
  'n',
  '<localleader>;',
  modify_line_end_delimiter(';'),
  { desc = 'append semi colon' }
)
