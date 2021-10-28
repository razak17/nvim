_GlobalCallbacks = _GlobalCallbacks or {}

_G.rvim = { _store = _GlobalCallbacks }

local fn = vim.fn
local fmt = string.format

local os = vim.loop.os_uname().sysname
rvim.templates_dir = get_config_dir() .. "/external/templates"
rvim.open_command = os == "Darwin" and "open" or "xdg-open"

function rvim._create(f)
  table.insert(rvim._store, f)
  return #rvim._store
end

function rvim._execute(id, args)
  rvim._store[id](args)
end

function rvim._create(f)
  table.insert(rvim._store, f)
  return #rvim._store
end

function rvim._execute(id, args)
  rvim._store[id](args)
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

local installed
---Check if a plugin is on the system not whether or not it is loaded
---@param plugin_name string
---@return boolean
function rvim.plugin_installed(plugin_name)
  if not installed then
    local dirs = fn.expand(get_runtime_dir() .. "/site/pack/packer/start/*", true, true)
    local opt = fn.expand(get_runtime_dir() .. "/site/pack/packer/opt/*", true, true)
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

---@class Autocommand
---@field events string[] list of autocommand events
---@field targets string[] list of autocommand patterns
---@field modifiers string[] e.g. nested, once
---@field command string | function

---@param command Autocommand
local function is_valid_target(command)
  local valid_type = command.targets and vim.tbl_islist(command.targets)
  return valid_type or vim.startswith(command.events[1], "User ")
end

local L = vim.log.levels
---Create an autocommand
---@param name string
---@param commands Autocommand[]
function rvim.augroup(name, commands)
  vim.cmd("augroup " .. name)
  vim.cmd "autocmd!"
  for _, c in ipairs(commands) do
    if c.command and c.events and is_valid_target(c) then
      local command = c.command
      if type(command) == "function" then
        local fn_id = rvim._create(command)
        command = fmt("lua rvim._execute(%s)", fn_id)
      end
      c.events = type(c.events) == "string" and { c.events } or c.events
      vim.cmd(
        fmt(
          "autocmd %s %s %s %s",
          table.concat(c.events, ","),
          table.concat(c.targets or {}, ","),
          table.concat(c.modifiers or {}, " "),
          command
        )
      )
    else
      vim.notify(fmt("An autocommand in %s is specified incorrectly: %s", name, vim.inspect(name)), L.ERROR)
    end
  end
  vim.cmd "augroup END"
end

---Require a module using [pcall] and report any errors
---@param module string
---@param opts table?
---@return boolean, any
function rvim.safe_require(module, opts)
  opts = opts or { silent = false }
  local ok, result = pcall(require, module)
  if not ok and not opts.silent then
    vim.notify(result, L.ERROR, { title = fmt("Error requiring: %s", module) })
  end
  return ok, result
end

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
