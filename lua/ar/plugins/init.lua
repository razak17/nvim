--- Get plugins spec
local plugins_path = vim.fn.stdpath('config') .. '/lua/ar/plugins'
local plugins_list = vim.fs.find(function(name, _)
  local filename = name:match('(.+)%.lua$')
  return name:match('.*.lua$')
    and not ar.module_disabled(filename)
    and not name:match('init')
end, { path = plugins_path, limit = math.huge, type = 'file' })
local spec = vim.iter(plugins_list):fold({}, function(acc, path)
  local _, pos = path:find(plugins_path)
  acc[#acc + 1] = { import = 'ar.plugins.' .. path:sub(pos + 2, #path - 4) }
  return acc
end)

-- print('DEBUGPRINT[367]: init.lua:17: spec=' .. vim.inspect(spec))
return spec
