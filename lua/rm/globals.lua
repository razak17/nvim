if not rvim then return end

local uv = vim.uv
local fn, api, cmd, fmt = vim.fn, vim.api, vim.cmd, string.format
local l = vim.log.levels

---Join path segments that were passed rvim input
---@return string
function join_paths(...)
  local path_sep = uv.os_uname().version:match('Windows') and '\\' or '/'
  local result = table.concat({ ... }, path_sep)
  return result
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

function rvim.remove_duplicates(table)
  local seen = {}
  return vim
    .iter(table)
    :filter(function(s)
      if not seen[s] then
        seen[s] = true
        return true
      end
      return false
    end)
    :totable()
end

function rvim.mergeTables(destination, source)
  for k, v in pairs(source) do
    if type(v) == 'table' and type(v[1]) == 'string' then
      for _, item in ipairs(v) do
        for _, existing in ipairs(destination[k]) do
          if existing == item then goto continue end
        end
        table.insert(destination[k], item)
        ::continue::
      end
    elseif type(v) == 'table' then
      if destination[k] == nil or type(destination[k]) ~= 'table' then destination[k] = {} end
      rvim.mergeTables(destination[k], v)
    else
      destination[k] = v
    end
  end
end

--- check for project local config
function rvim.project_config(file)
  if not file then return end
  local json = file:read('*a')
  local status, table = pcall(vim.fn.json_decode, json)
  io.close(file)
  if not status then
    vim.cmd("echohl ErrorMsg | echo 'Error: Invalid json' | echohl None")
    -- vim.notify('Invalid json found in .rvim.json', 'error')
    return
  end
  rvim.mergeTables(rvim, table)
end

--- Autosize horizontal split to match its minimum content
--- https://vim.fandom.com/wiki/Automatically_fitting_a_quickfix_window_height
---@param minheight number
---@param maxheight number
function rvim.adjust_split_height(minheight, maxheight)
  api.nvim_win_set_height(0, math.max(math.min(fn.line('$'), maxheight), minheight))
end

--- Call the given function and use `vim.notify` to notify of any errors
--- this function is a wrapper around `xpcall` which allows having a single
--- error handler for all errors
---@param msg? string
---@param func function
---@param ... any
---@return boolean, any
---@overload fun(func: function, ...): boolean, any
function rvim.pcall(msg, func, ...)
  local args = { ... }
  if type(msg) == 'function' then
    local arg = func
    args, func, msg = { arg, unpack(args) }, msg, nil
  end
  return xpcall(func, function(err)
    if rvim.debug.enable then
      msg = debug.traceback(msg and fmt('%s:\n%s\n%s', msg, vim.inspect(args), err) or err)
      vim.schedule(function() vim.notify(msg, l.ERROR, { title = 'ERROR' }) end)
    end
  end, unpack(args))
end

---Check if a target directory exists in a given table
---@param dir string
---@param dirs_table table
---@return boolean
function rvim.dirs_match(dirs_table, dir)
  for _, v in ipairs(dirs_table) do
    if dir:match(v) then return true end
  end
  return false
end

--- Check if a plugin is defined in lazy. Useful with lazy loading
--- when a plugin is not necessarily loaded yet.
---@param plugin string The plugin to search for.
---@return boolean available # Whether the plugin is available.
function rvim.is_available(plugin)
  local lazy_config_avail, lazy_config = pcall(require, 'lazy.core.config')
  return lazy_config_avail and lazy_config.plugins[plugin] ~= nil
end

---Get whether using nightly version of neovim
local LATEST_NIGHTLY_MINOR = 10
function rvim.nightly() return vim.version().minor >= LATEST_NIGHTLY_MINOR end

function rvim.reload_all() vim.cmd('checktime') end

function rvim.run_command(command, params, cb)
  local Job = require('plenary.job')
  local error_msg = nil
  Job:new({
    command = command,
    args = params,
    on_stderr = function(error, data, self)
      if error_msg == nil then error_msg = data end
    end,
    on_exit = function(self, code, signal)
      vim.schedule_wrap(function()
        if code == 0 then
          vim.notify(command .. ' executed successfully', vim.log.levels.INFO)
          if cb then cb() end
        else
          local info = { command .. ' failed!' }
          if error_msg ~= nil then
            table.insert(info, error_msg)
            print(error_msg)
          end
          vim.notify(info, vim.log.levels.ERROR)
        end
      end)()
    end,
  }):start()
  vim.notify(command .. ' launched...', vim.log.levels.INFO)
end

function rvim.escape_pattern(text) return text:gsub('([^%w])', '%%%1') end

function rvim.copy_to_clipboard(to_copy) vim.fn.setreg('+', to_copy) end

function rvim.load_colorscheme(name)
  rvim.pcall('theme failed to load because', vim.cmd.colorscheme, name)
end

--[[ create_select_menu()
-- Create a menu to execute a Vim command or Lua function using vim.ui.select()
-- Example usage:
-- local options = {
--   [1. Onedark ] = "colo onedark"
--   [2. Tokyonight ] = function() vim.cmd("colo tokyonight") end
-- }
-- local colo_picker = util.create_select_menu("Choose a colorscheme", options)
-- vim.api.nvim_create_user_command("ColoPicker", colo_picker, { nargs = 0 })
--
-- @arg prompt: the prompt to display
-- @arg options_table: Table of the form { [n. Display name] = lua-function/vim-cmd, ... }
--                    The number is used for the sorting purpose and will be replaced by vim.ui.select() numbering
--]]
-- Ref: https://github.com/theopn/theovim/blob/main/lua/util.lua#L12
function rvim.create_select_menu(prompt, options_table)
  -- Given the table of options, populate an array with option display names
  local option_names = {}
  local n = 0
  for i, _ in pairs(options_table) do
    n = n + 1
    option_names[n] = i
  end
  table.sort(option_names)
  -- Return the prompt function. These global function var will be used when assigning keybindings
  local menu = function()
    vim.ui.select(option_names, {
      prompt = prompt,
      format_item = function(item) return item:gsub('%d. ', '') end,
    }, function(choice)
      local action = options_table[choice]
      if action ~= nil then
        if type(action) == 'string' then
          vim.cmd(action)
        elseif type(action) == 'function' then
          action()
        end
      end
    end)
  end
  return menu
end

----------------------------------------------------------------------------------------------------
--  FILETYPE HELPERS
----------------------------------------------------------------------------------------------------

---@class FiletypeSettings
---@field g table<string, any>
---@field bo vim.bo
---@field wo vim.wo
---@field opt vim.opt
---@field plugins {[string]: fun(module: table)}

---@param args {[1]: string, [2]: string, [3]: string, [string]: boolean | integer}[]
---@param buf integer
local function apply_ft_mappings(args, buf)
  vim.iter(args):each(function(m)
    print('DEBUGPRINT[1]: globals.lua:154: m=' .. vim.inspect(m))
    -- assert(#m == 3, 'map args must be a table with at least 3 items')
    local opts = vim.iter(m):fold({ buffer = buf }, function(acc, key, item)
      if type(key) == 'string' then acc[key] = item end
      return acc
    end)
    map(m[1], m[2], m[3], opts)
  end)
end

--- A convenience wrapper that calls the ftplugin config for a plugin if it exists
--- and warns me if the plugin is not installed
---@param configs table<string, fun(module: table)>
function rvim.ftplugin_conf(configs)
  if type(configs) ~= 'table' then return end
  for name, callback in pairs(configs) do
    local ok, plugin = rvim.pcall(require, name)
    if ok then callback(plugin) end
  end
end

--- This function is an alternative API to using ftplugin files. It allows defining
--- filetype settings in a single place, then creating FileType autocommands from this definition
---
--- e.g.
--- ```lua
---   rvim.filetype_settings({
---     lua = {
---      opt = {foldmethod = 'expr' },
---      bo = { shiftwidth = 2 }
---     },
---    [{'c', 'cpp'}] = {
---      bo = { shiftwidth = 2 }
---    }
---   })
--- ```
--- One future idea is to generate the ftplugin files from this function, so the settings are still
--- centralized but the curation of these files is automated. Although I'm not sure this actually
--- has value over autocommands, unless ftplugin files specifically have that value
---@param map {[string|string[]]: FiletypeSettings | {[integer]: fun(args: AutocmdArgs)}}
function rvim.filetype_settings(map)
  local commands = vim.iter(map):map(function(ft, settings)
    local name = type(ft) == 'table' and table.concat(ft, ',') or ft
    return {
      pattern = ft,
      event = 'FileType',
      desc = ('ft settings for %s'):format(name),
      command = function(args)
        vim.iter(settings):each(function(key, value)
          if key == 'opt' then key = 'opt_local' end
          if key == 'mappings' then return apply_ft_mappings(value, args.buf) end
          if key == 'plugins' then return rvim.ftplugin_conf(value) end
          if type(key) == 'function' then return rvim.pcall(key, args) end
          vim.iter(value):each(function(option, setting) vim[key][option] = setting end)
        end)
      end,
    }
  end)
  rvim.augroup('filetype-settings', unpack(commands:totable()))
end

---@param str string
---@param max_len integer
---@return string
function rvim.truncate(str, max_len)
  assert(str and max_len, 'string and max_len must be provided')
  return api.nvim_strwidth(str) > max_len and str:sub(1, max_len) .. rvim.ui.icons.misc.ellipsis
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
  return vim.iter(fn.getwininfo()):find(function(win) return not rvim.falsy(win[list_type]) end)
    ~= nil
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
function rvim.list.qf.delete(buf)
  buf = buf or api.nvim_get_current_buf()
  local list = fn.getqflist()
  local line = api.nvim_win_get_cursor(0)[1]
  local mode = api.nvim_get_mode().mode
  if mode:match('[vV]') then
    local first_line = fn.getpos("'<")[2]
    local last_line = fn.getpos("'>")[2]
    list = vim.iter(ipairs(list)):filter(function(i) return i < first_line or i > last_line end)
  else
    table.remove(list, line)
  end
  -- replace items in the current list, do not make a new copy of it; this also preserves the list title
  fn.setqflist({}, 'r', { items = list })
  fn.setpos('.', { buf, line, 1, 0 }) -- restore current line
end
---------------------------------------------------------------------------------

---Determine if a value of any type is empty
---@param item any
---@return boolean
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

local autocmd_keys = { 'event', 'buffer', 'pattern', 'desc', 'command', 'group', 'once', 'nested' }
--- Validate the keys passed to rvim.augroup are valid
---@param name string
---@param command Autocommand
local function validate_autocmd(name, command)
  local incorrect = vim.iter(command):map(function(key, _)
    if not vim.tbl_contains(autocmd_keys, key) then return key end
  end)

  if #incorrect > 0 then
    vim.schedule(function()
      local msg = ('Incorrect keys: %s'):format(table.concat(incorrect, ', '))
      vim.notify(msg, 'error', { title = ('Autocmd: %s'):format(name) })
    end)
  end
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
---@field desc string?
---@field event  (string | string[])? list of autocommand events
---@field pattern (string | string[])? list of autocommand patterns
---@field command string | fun(args: AutocmdArgs): boolean?
---@field nested  boolean?
---@field once    boolean?
---@field buffer  number?

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
---@param name string
---@param rhs string | fun(args: CommandArgs)
---@param opts? table
function rvim.command(name, rhs, opts)
  opts = opts or {}
  api.nvim_create_user_command(name, rhs, opts)
end

---A terser proxy for `nvim_replace_termcodes`
---@param str string
---@return string
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

--- source: https://github.com/tjdevries/lazy-require.nvim

--- Require on index.
---
--- Will only require the module after the first index of a module.
--- Only works for modules that export a table.
function rvim.reqidx(require_path)
  return setmetatable({}, {
    __index = function(_, key) return require(require_path)[key] end,
    __newindex = function(_, key, value) require(require_path)[key] = value end,
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

---@param require_path string
---@return table<string, fun(...): any>
function rvim.reqcall(require_path)
  return setmetatable({}, {
    __index = function(_, k)
      return function(...) return require(require_path)[k](...) end
    end,
  })
end

---@param bool boolean
---@return string
function rvim.bool2str(bool) return bool and 'on' or 'off' end

function rvim.change_filetype()
  vim.ui.input({ prompt = 'Change filetype to: ' }, function(new_ft)
    if new_ft ~= nil then vim.bo.filetype = new_ft end
  end)
end
