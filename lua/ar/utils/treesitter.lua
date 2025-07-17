local M = {}

-- Gets a property at path
---@param tbl table the table to access
---@param path string the '.' separated path
---@return table|nil result the value at path or nil
function M.get_at_path(tbl, path)
  if path == '' then return tbl end

  local segments = vim.split(path, '.', true)
  ---@type table[]|table
  local result = tbl

  for _, segment in ipairs(segments) do
    if type(result) == 'table' then
      ---@type table
      -- TODO: figure out the actual type of tbl
      result = result[segment]
    end
  end

  return result
end

return M
