--- Get plugins spec
local plugins_path = vim.fn.stdpath('config') .. '/lua/ar/plugins'

-- Check if a module is disabled
---@param module string The module to search for.
---@return boolean disabled # Whether the module is disabled.
local function module_disabled(module)
  return vim.tbl_contains(ar_config.plugins.modules.disabled, module)
end

local plugins_list = vim.split(vim.fn.globpath(plugins_path, '*.lua'), '\n')
return vim
  .iter(plugins_list)
  :map(function(path) return string.match(path, 'lua/ar/plugins/(.+).lua$') end)
  :filter(function(f) return f ~= 'init' and not module_disabled(f) end)
  :map(function(module) return { import = 'ar.plugins.' .. module } end)
  :totable()
