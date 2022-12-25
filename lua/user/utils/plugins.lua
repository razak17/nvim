local fmt = string.format

local M = {}

---Require a plugin config
---@param dir string
---@param name string
---@return any
function M.load_conf(dir, name)
  local module_dir = fmt('user.modules.%s', dir)
  if dir == 'user' then return require(fmt(dir .. '.%s', name)) end

  return require(fmt(module_dir .. '.%s', name))
end

return M
