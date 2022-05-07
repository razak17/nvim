local fn = vim.fn
local fmt = string.format
local api = vim.api
local uv = vim.loop

----------------------------------------------------------------------------------------------------
-- Global namespace
----------------------------------------------------------------------------------------------------
_G.rvim = {
  mappings = {},
  lang = {},
  util = {},
}

---Join path segments that were passed rvim input
---@return string
function join_paths(...)
  local path_sep = uv.os_uname().version:match "Windows" and "\\" or "/"
  local result = table.concat({ ... }, path_sep)
  return result
end

---Get the full path to `$RVIM_RUNTIME_DIR`
---@return string
function rvim.get_runtime_dir()
  local rvim_runtime_dir = vim.env.RVIM_RUNTIME_DIR
  if not rvim_runtime_dir then
    -- when nvim is used directly
    return vim.call("stdpath", "data")
  end
  return rvim_runtime_dir
end

---Get the full path to `$RVIM_CONFIG_DIR`
---@return string
function rvim.get_config_dir()
  local rvim_config_dir = vim.env.RVIM_CONFIG_DIR
  if not rvim_config_dir then
    return vim.call("stdpath", "config")
  end
  return rvim_config_dir
end

---Get the full path to `$RVIM_CACHE_DIR`
---@return string
function rvim.get_cache_dir()
  local rvim_cache_dir = vim.env.RVIM_CACHE_DIR
  if not rvim_cache_dir then
    return vim.call("stdpath", "cache")
  end
  return rvim_cache_dir
end

---Get the full path to `$RVIM_CONFIG_DIR/lua/user`
---@return string
function rvim.get_user_dir()
  local config_dir = vim.env.RVIM_CONFIG_DIR
  if not config_dir then
    config_dir = vim.call("stdpath", "config")
  end
  return join_paths(config_dir, "lua", "user")
end

-----------------------------------------------------------------------------//
-- Utils
-----------------------------------------------------------------------------//

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

--- Check if a file or directory exists in this path
function rvim._exists(file)
  if file == "" or file == nil then
    return false
  end
  local ok, err, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      -- Permission denied, but it exists
      return true
    end
  end
  return ok, err
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

local oss = vim.loop.os_uname().sysname
rvim.open_command = oss == "Darwin" and "open" or "xdg-open"

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

----------------------------------------------------------------------------------------------------
-- API Wrappers
----------------------------------------------------------------------------------------------------
-- Thin wrappers over API functions to make their usage easier/terser

P = vim.pretty_print
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
      group = name,
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

---Source a lua or vimscript file
---@param path string path relative to the nvim directory
---@param prefix boolean?
function rvim.source(path, prefix)
  if not prefix then
    vim.cmd(fmt("source %s", path))
  else
    vim.cmd(fmt("source %s/%s", vim.g.vim_dir, path))
  end
end

---A terser proxy for `nvim_replace_termcodes`
---@param str string
---@return any
function rvim.replace_termcodes(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

---check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function rvim.has(feature)
  return vim.fn.has(feature) > 0
end

rvim.nightly = rvim.has "nvim-0.7"

----------------------------------------------------------------------------------------------------
-- Keymaps
----------------------------------------------------------------------------------------------------

---create a mapping function factory
---@param mode string
---@param o table
---@return fun(lhs: string, rhs: string, opts: table|nil) 'create a mapping'
local function make_mapper(mode, o)
  -- copy the opts table rvim extends will mutate the opts table passed in otherwise
  local parent_opts = vim.deepcopy(o)
  ---Create a mapping
  ---@param lhs string
  ---@param rhs string|function
  ---@param opts table
  return function(lhs, rhs, opts)
    -- If the label is all that was passed in, set the opts automagically
    opts = type(opts) == 'string' and { desc = opts } or opts and vim.deepcopy(opts) or {}
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("keep", opts, parent_opts))
  end
end

local map_opts = { remap = true, silent = true }
local noremap_opts = { silent = true }

-- A recursive commandline mapping
rvim.nmap = make_mapper("n", map_opts)
-- A recursive select mapping
rvim.xmap = make_mapper("x", map_opts)
-- A recursive terminal mapping
rvim.imap = make_mapper("i", map_opts)
-- A recursive operator mapping
rvim.vmap = make_mapper("v", map_opts)
-- A recursive insert mapping
rvim.omap = make_mapper("o", map_opts)
-- A recursive visual & select mapping
rvim.tmap = make_mapper("t", map_opts)
-- A recursive visual mapping
rvim.smap = make_mapper("s", map_opts) -- A recursive normal mapping
rvim.cmap = make_mapper("c", { remap = false, silent = false })
-- A non recursive normal mapping
rvim.nnoremap = make_mapper("n", noremap_opts)
-- A non recursive visual mapping
rvim.xnoremap = make_mapper("x", noremap_opts)
-- A non recursive visual & select mapping
rvim.vnoremap = make_mapper("v", noremap_opts)
-- A non recursive insert mapping
rvim.inoremap = make_mapper("i", noremap_opts)
-- A non recursive operator mapping
rvim.onoremap = make_mapper("o", noremap_opts)
-- A non recursive terminal mapping
rvim.tnoremap = make_mapper("t", noremap_opts)
-- A non recursive select mapping
rvim.snoremap = make_mapper("s", noremap_opts)
-- A non recursive commandline mapping
rvim.cnoremap = make_mapper("c", { silent = false })
