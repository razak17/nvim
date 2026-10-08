local core_path = vim.fn.stdpath('config') .. '/lua/ar/core'
local whitelist = {
  'lsp',
  'statuscolumn',
  'statusline',
  'winbar',
}

---@param core string
---@return boolean
local function enabled(core)
  return ar.config.plugin.core[core] and ar.config.plugin.core[core].enable
end

local plugins_list = vim.split(vim.fn.globpath(core_path, '*.lua'), '\n')
vim
  .iter(plugins_list)
  :map(function(path) return string.match(path, 'lua/ar/core/(.+)%.lua$') end)
  :filter(
    function(f)
      return vim.tbl_contains(whitelist, f) or (f ~= 'init' and enabled(f))
    end
  )
  :each(function(core) require('ar.core.' .. core) end)
