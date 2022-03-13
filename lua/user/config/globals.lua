local fn = vim.fn
local fmt = string.format
local api = vim.api

-----------------------------------------------------------------------------//
-- Global namespace
-----------------------------------------------------------------------------//
--- Inspired by @tjdevries' astraunauta.nvim/ @TimUntersberger's config
--- store all callbacks in one global table so they are able to survive re-requiring this file

_G.__rvim_global_callbacks = __rvim_global_callbacks or {}

_G.rvim = {
  _store = __rvim_global_callbacks,
  --- work around to place functions in the global scope but namespaced within a table.
  --- TODO: refactor this once nvim allows passing lua functions to mappings
  mappings = {},
}

-- inject keymaps helpers into the global namespace
require "user.utils.keymaps"

-----------------------------------------------------------------------------//
-- Debugging
-----------------------------------------------------------------------------//

local installed
---Check if a plugin is on the system not whether or not it is loaded
---@param plugin_name string
---@return boolean
function rvim.plugin_installed(plugin_name)
  if not installed then
    local dirs = fn.expand(rvim.get_runtime_dir() .. "/site/pack/packer/start/*", true, true)
    local opt = fn.expand(rvim.get_runtime_dir() .. "/site/pack/packer/opt/*", true, true)
    vim.list_extend(dirs, opt)
    installed = vim.tbl_map(function(path)
      return fn.fnamemodify(path, ":t")
    end, dirs)
  end
  return vim.tbl_contains(installed, plugin_name)
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

---Get the full path to `$RVIM_RUNTIME_DIR`
---@return string
function rvim.get_runtime_dir()
  local rvim_runtime_dir = os.getenv "RVIM_RUNTIME_DIR"
  if not rvim_runtime_dir then
    -- when nvim is used directly
    return vim.fn.stdpath "data"
  end
  return rvim_runtime_dir
end

---Get the full path to `$RVIM_CONFIG_DIR`
---@return string
function rvim.get_config_dir()
  local rvim_config_dir = os.getenv "RVIM_CONFIG_DIR"
  if not rvim_config_dir then
    return vim.fn.stdpath "config"
  end
  return rvim_config_dir
end

---Get the full path to `$RVIM_CACHE_DIR`
---@return string
function rvim.get_cache_dir()
  local rvim_cache_dir = os.getenv "RVIM_CACHE_DIR"
  if not rvim_cache_dir then
    return vim.fn.stdpath "cache"
  end
  return rvim_cache_dir
end

---Get the full path to `$RVIM_CONFIG_DIR/lua/user`
---@return string
function rvim.get_user_dir()
  local config_dir = os.getenv "RVIM_CONFIG_DIR"
  if not config_dir then
    config_dir = vim.fn.stdpath "config"
  end
  local rvim_config_dir = require("user.utils").join_paths(config_dir, "lua/user/")
  return rvim_config_dir
end

-----------------------------------------------------------------------------//
-- Utils
-----------------------------------------------------------------------------//

---Check whether or not the location or quickfix list is open
---@return boolean
function rvim.is_vim_list_open()
  for _, win in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(win)
    local location_list = fn.getloclist(0, { filewinid = 0 })
    local is_loc_list = location_list.filewinid > 0
    if vim.bo[buf].filetype == "qf" or is_loc_list then
      return true
    end
  end
  return false
end

function rvim._create(f)
  table.insert(rvim._store, f)
  return #rvim._store
end

function rvim._execute(id, args)
  rvim._store[id](args)
end

---@class Autocommand
---@field description string
---@field event  string[] list of autocommand events
---@field pattern string[] list of autocommand patterns
---@field command string | function
---@field nested  boolean
---@field once    boolean
---@field buffer  number

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string
---@param commands Autocommand[]
---@return number
function rvim.augroup(name, commands)
  local id = api.nvim_create_augroup(name, { clear = true })
  for _, autocmd in ipairs(commands) do
    local is_callback = type(autocmd.command) == "function"
    api.nvim_create_autocmd(autocmd.event, {
      group = id,
      pattern = autocmd.pattern,
      desc = autocmd.description,
      callback = is_callback and autocmd.command or nil,
      command = not is_callback and autocmd.command or nil,
      once = autocmd.once,
      nested = autocmd.nested,
      buffer = autocmd.buffer,
    })
  end
  return id
end

--- Disable autocommand groups if it exists
--- This is more reliable than trying to delete the augroup itself
---@param name string the augroup name
function rvim.disable_augroup(name)
  -- defer the function in case the autocommand is still in-use
  vim.schedule(function()
    if vim.fn.exists("#" .. name) == 1 then
      vim.cmd("augroup " .. name)
      vim.cmd "autocmd!"
      vim.cmd "augroup END"
    end
  end)
end

---Require a module using [pcall] and report any errors
---@param module string
---@param opts table?
---@return boolean, any
function rvim.safe_require(module, opts)
  opts = opts or { silent = false }
  local ok, result = pcall(require, module)
  if not ok and not opts.silent then
    vim.notify(result, vim.log.levels.ERROR, { title = fmt("Error requiring: %s", module) })
  end
  return ok, result
end

---Determine if a value of any type is empty
---@param item any
---@return boolean
function rvim.empty(item)
  if not item then
    return true
  end
  local item_type = type(item)
  if item_type == "string" then
    return item == ""
  elseif item_type == "table" then
    return vim.tbl_isempty(item)
  end
end

---Create an nvim command
---@param args table
function rvim.command(args)
  local nargs = args.nargs or 0
  local name = args[1]
  local rhs = args[2]
  local types = (args.types and type(args.types) == "table") and table.concat(args.types, " ") or ""

  if type(rhs) == "function" then
    local fn_id = rvim._create(rhs)
    rhs = fmt("lua rvim._execute(%d%s)", fn_id, nargs > 0 and ", <f-args>" or "")
  end

  vim.cmd(fmt("command! -nargs=%s %s %s %s", nargs, types, name, rhs))
end

--- Usage:
--- 1. Call `local stop = utils.profile('my-log')` at the top of the file
--- 2. At the bottom of the file call `stop()`
--- 3. Restart neovim, the newly created log file should open
function rvim.profile(filename)
  local base = "/tmp/config/profile/"
  fn.mkdir(base, "p")
  local success, profile = pcall(require, "plenary.profile.lua_profiler")
  if not success then
    vim.api.nvim_echo({ "Plenary is not installed.", "Title" }, true, {})
  end
  profile.start()
  return function()
    profile.stop()
    local logfile = base .. filename .. ".log"
    profile.report(logfile)
    vim.defer_fn(function()
      vim.cmd("tabedit " .. logfile)
    end, 1000)
  end
end

---check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function rvim.has(feature)
  return vim.fn.has(feature) > 0
end

local oss = vim.loop.os_uname().sysname
rvim.open_command = oss == "Darwin" and "open" or "xdg-open"

function rvim.T(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

--- Utility function to toggle the location or the quickfix list
---@param list_type '"quickfix"' | '"location"'
---@return nil
function rvim.toggle_list(list_type)
  local is_location_target = list_type == "location"
  local prefix = is_location_target and "l" or "c"
  local is_open = rvim.is_vim_list_open()
  if is_open then
    return fn.execute(prefix .. "close")
  end
  local list = is_location_target and fn.getloclist(0) or fn.getqflist()
  if vim.tbl_isempty(list) then
    local msg_prefix = (is_location_target and "Location" or "QuickFix")
    return vim.notify(msg_prefix .. " List is Empty.", L.WARN)
  end

  local winnr = fn.winnr()
  fn.execute(prefix .. "open")
  if fn.winnr() ~= winnr then
    vim.cmd "wincmd p"
  end
end

---Reload lua modules
---@param path string
---@param recursive string
function rvim.invalidate(path, recursive)
  if recursive then
    for key, value in pairs(package.loaded) do
      if key ~= "_G" and value and fn.match(key, path) ~= -1 then
        package.loaded[key] = nil
        require(key)
      end
    end
  else
    package.loaded[path] = nil
    require(path)
  end
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
