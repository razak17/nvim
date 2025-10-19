local fn = vim.fn
local L = vim.log.levels
local config_path = fn.stdpath('config')

local M = {}

-- local function read_lua_list(path)
--   local ok, list = pcall(
--     function() return dofile(config_path .. '/' .. path) end
--   )
--   if ok and type(list) == 'table' then
--     return list
--   else
--     error('Failed to read list from ' .. path)
--   end
-- end

local function write_md(path, title, list)
  local f = assert(io.open(config_path .. '/' .. path, 'w'))
  f:write('## ' .. title .. '\n\n')
  for _, item in ipairs(list) do
    f:write('- ' .. item .. '\n')
  end
  f:close()
end

local function update_json_enum(json, keys, new_list)
  -- keys: {"properties", "lsp", "properties", "override", "items", "enum"}
  local t = json
  for i = 1, #keys - 1 do
    t = t[keys[i]]
  end
  t[keys[#keys]] = new_list
end

local function generate_plugin_modules()
  local plugin_dir = fn.stdpath('config') .. '/lua/ar/plugins'
  local files = {}
  local ok, scan = pcall(require, 'plenary.scandir')
  if ok then
    files = scan.scan_dir(plugin_dir, { depth = 1, add_dirs = false })
  else
    -- fallback to vim.loop
    local luv = vim.loop
    local handle = luv.fs_scandir(plugin_dir)
    if handle then
      while true do
        local name, t = luv.fs_scandir_next(handle)
        if not name then break end
        if t == 'file' then table.insert(files, plugin_dir .. '/' .. name) end
      end
    end
  end

  local file_names = {}
  for _, f in ipairs(files) do
    local fname = f:match('([^/]+)$')
    local name_no_ext = fname:match('(.+)%.lua$') or fname
    table.insert(file_names, name_no_ext)
  end
  table.sort(file_names, function(a, b) return a:lower() < b:lower() end)
  return file_names
end

local function update_schema(
  schema_path,
  lsp_servers,
  plugin_modules,
  colorschemes
)
  local lunajson = require('lunajson')
  local json = assert(io.open(schema_path, 'r')):read('*a')
  local schema = assert(lunajson.decode(json))

  -- Update LSP servers enums
  local lsp_keys = {
    { 'properties', 'lsp', 'properties', 'override', 'items', 'enum' },
    {
      'properties',
      'lsp',
      'properties',
      'disabled',
      'properties',
      'servers',
      'items',
      'enum',
    },
  }
  for _, keys in ipairs(lsp_keys) do
    update_json_enum(schema, keys, lsp_servers)
  end

  -- Update plugin modules enums
  local plugin_keys = {
    {
      'properties',
      'plugins',
      'properties',
      'modules',
      'properties',
      'disabled',
      'items',
      'enum',
    },
    {
      'properties',
      'plugins',
      'properties',
      'modules',
      'properties',
      'override',
      'items',
      'enum',
    },
  }
  for _, keys in ipairs(plugin_keys) do
    update_json_enum(schema, keys, plugin_modules)
  end

  -- Update colorscheme enum
  update_json_enum(
    schema,
    { 'properties', 'colorscheme', 'enum' },
    colorschemes
  )

  local out = assert(io.open(schema_path, 'w'))
  out:write(lunajson.encode(schema, { indent = true }))
  out:close()

  if fn.executable('prettier') == 1 then
    fn.system({ 'prettier', '--write', schema_path })
  end
end

function M.update()
  local has_lunajson, _ = pcall(require, 'lunajson')
  if not has_lunajson then
    vim.notify(
      '[ERROR] lunajson Lua module is not installed. Please install lunajson to use this update script.',
      L.ERROR
    )
    return
  end

  local ok, err = pcall(function()
    local lsp_servers = require('ar.servers').names('all')
    vim.list_extend(lsp_servers, { 'typescript-tools' })
    table.sort(lsp_servers, function(a, b) return a:lower() < b:lower() end)
    local plugin_modules = generate_plugin_modules()
    local colorschemes = fn.getcompletion('', 'color')
    table.sort(colorschemes, function(a, b) return a:lower() < b:lower() end)

    write_md('SERVERS.md', '🚀 LSP Servers', lsp_servers)
    write_md('PLUGIN_MODULES.md', '📦 Plugin Modules', plugin_modules)
    write_md('COLORSCHEMES.md', '🎨 Colorschemes', colorschemes)

    update_schema(
      config_path .. '/rvim.schema.json',
      lsp_servers,
      plugin_modules,
      colorschemes
    )
  end)

  if ok then
    vim.notify(
      'Updated SERVERS.md, PLUGIN_MODULES.md, COLORSCHEMES.md, and rvim.schema.json from canonical lists.',
      L.INFO
    )
  else
    vim.notify('Error updating schema and docs: ' .. tostring(err), L.ERROR)
  end
end

return M
