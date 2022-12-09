if not rvim then return end

local fn = vim.fn
local fmt = string.format
local api = vim.api
local uv = vim.loop
local oss = vim.loop.os_uname().sysname
local l = vim.log.levels

rvim.open_command = oss == 'Darwin' and 'open' or 'xdg-open'

---Join path segments that were passed rvim input
---@return string
function join_paths(...)
  local path_sep = uv.os_uname().version:match('Windows') and '\\' or '/'
  local result = table.concat({ ... }, path_sep)
  return result
end

---Require a module in protected mode without relying on its cached value
---@param module string
---@return any
function require_clean(module)
  package.loaded[module] = nil
  _G[module] = nil
  local status, requested = pcall(require, module)
  if not status then return end
  return requested
end

---Get the full path to `$RVIM_RUNTIME_DIR`
---@return string
function rvim.get_runtime_dir()
  local rvim_runtime_dir = vim.env.RVIM_RUNTIME_DIR
  if not rvim_runtime_dir then
    -- when nvim is used directly
    return vim.call('stdpath', 'data')
  end
  return rvim_runtime_dir
end

---Get the full path to `$RVIM_CONFIG_DIR`
---@return string
function rvim.get_config_dir()
  local rvim_config_dir = vim.env.RVIM_CONFIG_DIR
  if not rvim_config_dir then return vim.call('stdpath', 'config') end
  return rvim_config_dir
end

---Get the full path to `$RVIM_CACHE_DIR`
---@return string
function rvim.get_cache_dir()
  local rvim_cache_dir = vim.env.RVIM_CACHE_DIR
  if not rvim_cache_dir then return vim.call('stdpath', 'cache') end
  return rvim_cache_dir
end

---Get the full path to `$RVIM_CONFIG_DIR/lua/user`
---@return string
function rvim.get_user_dir()
  local config_dir = vim.env.RVIM_CONFIG_DIR
  if not config_dir then config_dir = vim.call('stdpath', 'config') end
  return join_paths(config_dir, 'lua', 'user')
end

----------------------------------------------------------------------------------------------------
-- Utils
----------------------------------------------------------------------------------------------------

--- Checks whether a given path exists and is a directory
--@param path (string) path to check
--@returns (bool)
function rvim.is_directory(path)
  local stat = uv.fs_stat(path)
  return stat and stat.type == 'directory' or false
end

--- Convert a list or map of items into a value by iterating all it's fields and transforming
--- them with a callback
---@generic T : table
---@param callback fun(T, T, key: string | number): T
---@param list T[]
---@param accum T
---@return T?
function rvim.fold(callback, list, accum)
  accum = accum or {}
  for k, v in pairs(list) do
    accum = callback(accum, v, k)
    assert(accum ~= nil, 'The accumulator must be returned on each iteration')
  end
  return accum
end

---@generic T : table
---@param callback fun(item: T, key: string | number, list: T[]): T
---@param list T[]
---@return T[]
function rvim.map(callback, list)
  return rvim.fold(function(accum, v, k)
    accum[#accum + 1] = callback(v, k, accum)
    return accum
  end, list, {})
end

---@generic T : table
---@param callback fun(T, key: string | number): T
---@param list T[]
function rvim.foreach(callback, list)
  for k, v in pairs(list) do
    callback(v, k)
  end
end

--- Check if the target matches  any item in the list.
---@param target string
---@param list string[]
---@return boolean
function rvim.any(target, list)
  for _, item in ipairs(list) do
    if target:match(item) then return true end
  end
  return false
end

---Find an item in a list
---@generic T
---@param haystack T[]
---@param matcher fun(arg: T):boolean
---@return T
function rvim.find(haystack, matcher)
  local found
  for _, needle in ipairs(haystack) do
    if matcher(needle) then
      found = needle
      break
    end
  end
  return found
end

--  find string in list
function rvim.find_string(table, string)
  local found = false
  for _, v in pairs(table) do
    if v == string then
      found = true
      break
    end
  end
  return found
end

---Some plugins are not safe to be reloaded because their setup functions
---and are not idempotent. This wraps the setup calls of such plugins
---@param func fun()
function rvim.block_reload(func)
  if vim.g.packer_compiled_loaded then return end
  func()
end

rvim.list_installed_plugins = (function()
  local plugins
  return function()
    if plugins then return plugins end
    local data_dir = rvim.get_runtime_dir()
    local start = fn.expand(data_dir .. '/site/pack/packer/start/*', true, true)
    local opt = fn.expand(data_dir .. '/site/pack/packer/opt/*', true, true)
    plugins = vim.list_extend(start, opt)
    return plugins
  end
end)()

---Check if a plugin is on the system not whether or not it is loaded
---@param plugin_name string
---@return boolean
function rvim.plugin_installed(plugin_name)
  for _, path in ipairs(rvim.list_installed_plugins()) do
    if vim.endswith(path, plugin_name) then return true end
  end
  return false
end

---NOTE: this plugin returns the currently loaded state of a plugin given
---given certain assumptions i.e. it will only be true if the plugin has been
---loaded e.g. lazy loading will return false
---@param plugin_name string
---@return boolean?
function rvim.plugin_loaded(plugin_name)
  local plugins = packer_plugins or {}
  return plugins[plugin_name] and plugins[plugin_name].loaded
end

---Check whether or not the location or quickfix list is open
---@return boolean
function rvim.is_vim_list_open()
  for _, win in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(win)
    local location_list = fn.getloclist(0, { filewinid = 0 })
    local is_loc_list = location_list and location_list.filewinid > 0
    if vim.bo[buf].filetype == 'qf' or is_loc_list then return true end
  end
  return false
end

---Require a module using [pcall] and report any errors
---@param module string
---@param opts table?
---@return boolean, any
function rvim.safe_require(module, opts)
  opts = opts or { silent = false }
  local ok, result = pcall(require, module)
  if not ok and not opts.silent then
    if opts.message then result = opts.message .. '\n' .. result end
    vim.notify(result, l.ERROR, { title = fmt('Error requiring: %s', module) })
  end
  return ok, result
end

--- Call the given function and use `vim.notify` to notify of any errors
--- this function is a wrapper around `xpcall` which allows having a single
--- error handler for all errors
---@param msg? string
---@param func function
---@vararg any
---@return boolean, any
---@overload fun(fun: function, ...): boolean, any
function rvim.wrap_err(msg, func, ...)
  local args = { ... }
  if type(msg) == 'function' then
    args, func, msg = { func, unpack(args) }, msg, nil
  end
  return xpcall(func, function(err)
    msg = msg and fmt('%s:\n%s', msg, err) or err
    vim.schedule(function() vim.notify(msg, l.ERROR, { title = 'ERROR' }) end)
  end, unpack(args))
end

---@alias Plug table<(string | number), string>

--- A convenience wrapper that calls the ftplugin config for a plugin if it exists
--- and warns me if the plugin is not installed
--- TODO: find out if it's possible to annotate the plugin rvim a module
---@param name string | Plug
---@param callback fun(module: table)
function rvim.ftplugin_conf(name, callback)
  local plugin_name = type(name) == 'table' and name.plugin or nil
  if plugin_name and not rvim.plugin_loaded(plugin_name) then return end

  local module = type(name) == 'table' and name[1] or name
  local info = debug.getinfo(1, 'S')
  local ok, plugin = rvim.safe_require(module, { message = fmt('In file: %s', info.source) })

  if ok then callback(plugin) end
end

---@param str string
---@param max_len integer
---@return string
function rvim.truncate(str, max_len)
  assert(str and max_len, 'string and max_len must be provided')
  return api.nvim_strwidth(str) > max_len and str:sub(1, max_len) .. rvim.style.icons.misc.ellipsis
    or str
end

---Determine if a value of any type is empty
---@param item any
---@return boolean?
function rvim.empty(item)
  if not item then return true end
  local item_type = type(item)
  if item_type == 'string' then return item == '' end
  if item_type == 'number' then return item <= 0 end
  if item_type == 'table' then return vim.tbl_isempty(item) end
  return item ~= nil
end

---Reload lua modules
---@param path any
---@param recursive boolean
function rvim.invalidate(path, recursive)
  if recursive then
    for key, value in pairs(package.loaded) do
      if key ~= '_G' and value and fn.match(key, path) ~= -1 then
        package.loaded[key] = nil
        require(key)
      end
    end
    return
  end
  package.loaded[path] = nil
  require(path)
end

----------------------------------------------------------------------------------------------------
-- API Wrappers
----------------------------------------------------------------------------------------------------
-- Thin wrappers over API functions to make their usage easier/terser

P = vim.pretty_print

--- Validate the keys passed to rvim.augroup are valid
---@param name string
---@param cmd Autocommand
local function validate_autocmd(name, cmd)
  local keys = { 'event', 'buffer', 'pattern', 'desc', 'command', 'group', 'once', 'nested' }
  local incorrect = rvim.fold(function(accum, _, key)
    if not vim.tbl_contains(keys, key) then table.insert(accum, key) end
    return accum
  end, cmd, {})
  if #incorrect == 0 then return end
  vim.schedule(
    function()
      vim.notify('Incorrect keys: ' .. table.concat(incorrect, ', '), 'error', {
        title = fmt('Autocmd: %s', name),
      })
    end
  )
end

---@class AutocmdArgs
---@field id number
---@field event string
---@field group string?
---@field buf number
---@field file string
---@field match string | number
---@field data any

---@class Autocommand
---@field desc string
---@field event  string[] | string list of autocommand events
---@field pattern string[] list of autocommand patterns
---@field command string | fun(args: AutocmdArgs): boolean?
---@field nested  boolean
---@field once    boolean
---@field buffer  number

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string
---@param commands Autocommand[]
---@return number
function rvim.augroup(name, commands)
  assert(name ~= 'User', 'The name of an augroup CANNOT be User')
  assert(#commands > 0, fmt('You must specify at least one autocommand for %s', name))
  local id = api.nvim_create_augroup(name, { clear = true })
  for _, autocmd in ipairs(commands) do
    validate_autocmd(name, autocmd)
    local is_callback = type(autocmd.command) == 'function'
    api.nvim_create_autocmd(autocmd.event, {
      group = name,
      pattern = autocmd.pattern,
      desc = autocmd.desc,
      callback = is_callback and autocmd.command or nil,
      command = not is_callback and autocmd.command or nil,
      once = autocmd.once,
      nested = autocmd.nested,
      buffer = autocmd.buffer,
    })
  end
  return id
end

--- @class CommandArgs
--- @field args string
--- @field fargs table
--- @field bang boolean,

---Create an nvim command
---@param name any
---@param rhs string|fun(args: CommandArgs)
---@param opts table
function rvim.command(name, rhs, opts)
  opts = opts or {}
  api.nvim_create_user_command(name, rhs, opts)
end

---Check if a cmd is executable
---@param e string
---@return boolean
function rvim.executable(e) return fn.executable(e) > 0 end

---A terser proxy for `nvim_replace_termcodes`
---@param str string
---@return any
function rvim.replace_termcodes(str) return api.nvim_replace_termcodes(str, true, true, true) end

---check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function rvim.has(feature) return vim.fn.has(feature) > 0 end

----------------------------------------------------------------------------------------------------
-- Mappings
----------------------------------------------------------------------------------------------------

--- remove key from table
---@param table table
---@param key string
---@return table
function rvim.removekey(table, key)
  table[key] = nil
  return table
end

--- add mapping only if plugin is installed
---@param desc string
---@param plugin string
---@param useInstalled boolean|nil
---@return table
function rvim.with_plugin(desc, plugin, useInstalled)
  if useInstalled == true then return { desc = desc, plugin = plugin, useInstalled = true } end
  return { desc = desc, plugin = plugin }
end

---create a mapping function factory
---@param mode string
---@param o table
---@return fun(lhs: string, rhs: string|function, opts: table|nil) 'create a mapping'
local function make_mapper(mode, o)
  -- copy the opts table rvim extends will mutate the opts table passed in otherwise
  local parent_opts = vim.deepcopy(o)
  ---Create a mapping
  ---@param lhs string
  ---@param rhs string|function
  ---@param opts table
  return function(lhs, rhs, opts)
    -- check if plugin is installed if plugin option and useInstalled are passed in opts
    if type(opts) == 'table' then
      if opts.plugin and opts.useInstalled then
        local installed = rvim.plugin_installed(opts.plugin)
        rvim.removekey(opts, 'plugin')
        rvim.removekey(opts, 'useInstalled')
        if not installed then return end
      elseif opts.plugin then
        local loaded = rvim.plugin_loaded(opts.plugin)
        rvim.removekey(opts, 'plugin')
        if not loaded then return end
      end
    end
    -- If the label is all that was passed in, set the opts automagically
    opts = type(opts) == 'string' and { desc = opts } or opts and vim.deepcopy(opts) or {}
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('keep', opts, parent_opts))
  end
end

local map_opts = { remap = true, silent = true }
local noremap_opts = { silent = true }

-- A recursive commandline mapping
rvim.nmap = make_mapper('n', map_opts)
-- A recursive select mapping
rvim.xmap = make_mapper('x', map_opts)
-- A recursive terminal mapping
rvim.imap = make_mapper('i', map_opts)
-- A recursive operator mapping
rvim.vmap = make_mapper('v', map_opts)
-- A recursive insert mapping
rvim.omap = make_mapper('o', map_opts)
-- A recursive visual & select mapping
rvim.tmap = make_mapper('t', map_opts)
-- A recursive visual mapping
rvim.smap = make_mapper('s', map_opts) -- A recursive normal mapping
rvim.cmap = make_mapper('c', { remap = false, silent = false })
-- A non recursive normal mapping
rvim.nnoremap = make_mapper('n', noremap_opts)
-- A non recursive visual mapping
rvim.xnoremap = make_mapper('x', noremap_opts)
-- A non recursive visual & select mapping
rvim.vnoremap = make_mapper('v', noremap_opts)
-- A non recursive insert mapping
rvim.inoremap = make_mapper('i', noremap_opts)
-- A non recursive operator mapping
rvim.onoremap = make_mapper('o', noremap_opts)
-- A non recursive terminal mapping
rvim.tnoremap = make_mapper('t', noremap_opts)
-- A non recursive select mapping
rvim.snoremap = make_mapper('s', noremap_opts)
-- A non recursive commandline mapping
rvim.cnoremap = make_mapper('c', { silent = false })
