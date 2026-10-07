local extras_path = vim.fn.stdpath('config') .. '/lua/ar/extras'

-- Check if a extra is enabled
---@param extra string The extra to search for.
---@return boolean enabled # Whether the extra is enabled.
local function extra_enabled(extra)
  return ar.config.plugin.extra[extra] and ar.config.plugin.extra[extra].enable
end

local plugins_list = vim.split(vim.fn.globpath(extras_path, '*.lua'), '\n')
vim
  .iter(plugins_list)
  :map(function(path) return string.match(path, 'lua/ar/extras/(.+)%.lua$') end)
  :filter(function(f) return f ~= 'init' and extra_enabled(f) end)
  :each(function(extra) require('ar.extras.' .. extra) end)
