if not rvim then return end

local uv = vim.loop
local fn, api, cmd, fmt = vim.fn, vim.api, vim.cmd, string.format
local l = vim.log.levels

---Join path segments that were passed rvim input
---@return string
function join_paths(...)
  local path_sep = uv.os_uname().version:match('Windows') and '\\' or '/'
  local result = table.concat({ ... }, path_sep)
  return result
end

---Get whether using nightly version of neovim
local LATEST_NIGHTLY_MINOR = 9
function rvim.nightly() return vim.version().minor >= LATEST_NIGHTLY_MINOR end

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
---@generic T, S
---@param callback fun(acc: S, item: T, key: string | number): S
---@param list T[]
---@param accum S?
---@return S
function rvim.fold(callback, list, accum)
  accum = accum or {}
  for k, v in pairs(list) do
    accum = callback(accum, v, k)
    assert(accum ~= nil, 'The accumulator must be returned on each iteration')
  end
  return accum
end

---@generic T
---@param callback fun(item: T, key: string | number)
---@return T[]
function rvim.map(callback, list)
  return rvim.fold(function(accum, v, k)
    accum[#accum + 1] = callback(v, k, accum)
    return accum
  end, list, {})
end

---@generic T : table
---@param callback fun(T, key: string | number)
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
---@param matcher fun(arg: T):boolean
---@param haystack T[]
---@return T
function rvim.find(matcher, haystack)
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

--- Autosize horizontal split to match its minimum content
--- https://vim.fandom.com/wiki/Automatically_fitting_a_quickfix_window_height
---@param minheight number
---@param maxheight number
function rvim.adjust_split_height(minheight, maxheight)
  api.nvim_win_set_height(0, math.max(math.min(fn.line('$'), maxheight), minheight))
end

---Require a module using [pcall] and report any errors
---@param module string
---@param opts {silent: boolean, message: string}?
---@return boolean, any
function rvim.require(module, opts)
  opts = opts or { silent = false }
  local ok, result = pcall(require, module)
  if not ok and not opts.silent then
    if opts.message then result = opts.message .. '\n' .. result end
    vim.schedule(
      function() vim.notify(result, l.ERROR, { title = fmt('Error requiring: %s', module) }) end
    )
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

--- A convenience wrapper that calls the ftplugin config for a plugin if it exists
--- and warns me if the plugin is not installed
--- TODO: find out if it's possible to annotate the plugin rvim a module
---@param configs table<string, fun(module: table)>
---@param opts {silent: boolean}?
function rvim.ftplugin_conf(configs, opts)
  if type(configs) ~= 'table' then return end
  opts = opts or { silent = true }
  for name, callback in pairs(configs) do
    local info = debug.getinfo(1, 'S')
    local ok, plugin = rvim.require(name, {
      message = fmt('In file: %s', info.source),
      silent = opts.silent,
    })
    if ok then callback(plugin) end
  end
end

---@param str string
---@param max_len integer
---@return string
function rvim.truncate(str, max_len)
  assert(str and max_len, 'string and max_len must be provided')
  return api.nvim_strwidth(str) > max_len and str:sub(1, max_len) .. rvim.ui.icons.ui.ellipsis
    or str
end

--- search current word or go to file
--- replicate netrw functionality
---@param path string
function rvim.open(path)
  fn.jobstart({ rvim.open_command, path }, { detach = true })
  vim.notify(fmt('Opening %s', path))
end

--- search current word in website. see usage below
---@param path string
---@param url string
function rvim.web_search(path, url)
  local query = '"' .. fn.substitute(path, '["\n]', ' ', 'g') .. '"'
  rvim.open(fmt('%s%s', url, query))
end

---------------------------------------------------------------------------------
-- Quickfix and Location List
---------------------------------------------------------------------------------
rvim.list = { qf = {}, loc = {} }

---@param list_type "loclist" | "quickfix"
---@return boolean
local function is_list_open(list_type)
  return rvim.find(function(win) return not rvim.falsy(win[list_type]) end, fn.getwininfo()) ~= nil
end

local silence = { mods = { silent = true, emsg_silent = true } }

---@param callback fun(...)
local function preserve_window(callback, ...)
  local win = api.nvim_get_current_win()
  callback(...)
  if win ~= api.nvim_get_current_win() then cmd.wincmd('p') end
end

function rvim.list.qf.toggle()
  if is_list_open('quickfix') then
    cmd.cclose(silence)
  elseif #fn.getqflist() > 0 then
    preserve_window(cmd.copen, silence)
  end
end

function rvim.list.loc.toggle()
  if is_list_open('loclist') then
    cmd.lclose(silence)
  elseif #fn.getloclist(0) > 0 then
    preserve_window(cmd.lopen, silence)
  end
end

-- @see: https://vi.stackexchange.com/a/21255
-- using range-aware function
function rvim.list.qf.delete(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  local list = fn.getqflist()
  local line = api.nvim_win_get_cursor(0)[1]
  -- FIXME: get visual selection so this functionality can work in visual mode
  if api.nvim_get_mode().mode == 'v' then
    local first_line = api.nvim_buf_get_mark(0, '<')[1]
    local last_line = api.nvim_buf_get_mark(0, '>')[1]
    list = rvim.fold(function(accum, item, i)
      if i < first_line or i > last_line then table.insert(accum, item) end
      return accum
    end, list)
  else
    table.remove(list, line)
  end
  -- replace items in the current list, do not make a new copy of it; this also preserves the list title
  fn.setqflist({}, 'r', { items = list })
  fn.setpos('.', { bufnr, line, 1, 0 }) -- restore current line
end
---------------------------------------------------------------------------------

---Determine if a value of any type is empty
---@param item any
---@return boolean?
function rvim.falsy(item)
  if not item then return true end
  local item_type = type(item)
  if item_type == 'boolean' then return not item end
  if item_type == 'string' then return item == '' end
  if item_type == 'number' then return item <= 0 end
  if item_type == 'table' then return vim.tbl_isempty(item) end
  return item ~= nil
end

----------------------------------------------------------------------------------------------------
-- API Wrappers
----------------------------------------------------------------------------------------------------
-- Thin wrappers over API functions to make their usage easier/terser

P = vim.pretty_print

--- Validate the keys passed to rvim.augroup are valid
---@param name string
---@param _cmd Autocommand
local function validate_autocmd(name, _cmd)
  local keys = { 'event', 'buffer', 'pattern', 'desc', 'command', 'group', 'once', 'nested' }
  local incorrect = rvim.fold(function(accum, _, key)
    if not vim.tbl_contains(keys, key) then table.insert(accum, key) end
    return accum
  end, _cmd, {})
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
---@field event  string | string[] list of autocommand events
---@field pattern string | string[] list of autocommand patterns
---@field command string | fun(args: AutocmdArgs): boolean?
---@field nested  boolean
---@field once    boolean
---@field buffer  number

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string The name of the autocommand group
---@param ... Autocommand A list of autocommands to create
---@return number
function rvim.augroup(name, ...)
  local commands = { ... }
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

---@generic T
---Given a table return a new table which if the key is not found will search
---all the table's keys for a match using `string.match`
---@param map T
---@return T
function rvim.p_table(map)
  return setmetatable(map, {
    __index = function(tbl, key)
      if not key then return end
      for k, v in pairs(tbl) do
        if key:match(k) then return v end
      end
    end,
  })
end

---check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function rvim.has(feature) return vim.fn.has(feature) > 0 end

--- Find the first entry for which the predicate returns true.
-- @param t The table
-- @param predicate The function called for each entry of t
-- @return The entry for which the predicate returned True or nil
function rvim.find_first(t, predicate)
  for _, entry in pairs(t) do
    if predicate(entry) then return entry end
  end
  return nil
end
