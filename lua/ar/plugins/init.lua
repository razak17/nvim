--- Get plugins spec
local plugins_path = vim.fn.stdpath('config') .. '/lua/ar/plugins'

-- Check if a module is disabled
---@param module string The module to search for.
---@return boolean disabled # Whether the module is disabled.
local function module_disabled(module)
  return ar.find_string(ar_config.plugins.modules.disabled, module)
end

local plugins_list = vim.fs.find(function(name, _)
  local filename = name:match('(.+)%.lua$')
  return name:match('.*.lua$')
    and not module_disabled(filename)
    and not name:match('init')
end, { path = plugins_path, limit = math.huge, type = 'file' })
local spec = vim.iter(plugins_list):fold({}, function(acc, path)
  local _, pos = path:find(plugins_path)
  acc[#acc + 1] = { import = 'ar.plugins.' .. path:sub(pos + 2, #path - 4) }
  return acc
end)

return spec
