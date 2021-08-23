_GlobalCallbacks = _GlobalCallbacks or {}

_G.rvim = { _store = _GlobalCallbacks }

local api, fn = vim.api, vim.fn
local fmt = string.format

-- -- Messaging
-- if vim.notify then
--   ---Override of vim.notify to open floating window
--   --@param message of the notification to show to the user
--   --@param log_level Optional log level
--   --@param opts Dictionary with optional options (timeout, etc)
--   vim.notify = function(message, log_level, _)
--     assert(message, "The message key of vim.notify should be a string")
--     rvim.notify(message, { timeout = 5000, log_level = log_level })
--   end
-- end

rvim.t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function rvim._create(f)
  table.insert(rvim._store, f)
  return #rvim._store
end

function rvim._execute(id, args)
  rvim._store[id](args)
end

local installed
---Check if a plugin is on the system not whether or not it is loaded
---@param plugin_name string
---@return boolean
function rvim.plugin_installed(plugin_name)
  if not installed then
    local dirs = fn.expand(fn.stdpath "data" .. "/site/pack/packer/start/*", true, true)
    local opt = fn.expand(fn.stdpath "data" .. "/site/pack/packer/opt/*", true, true)
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

-----------------------------------------------------------------------------//
-- Utils
-----------------------------------------------------------------------------//
function rvim._create(f)
  table.insert(rvim._store, f)
  return #rvim._store
end

function rvim._execute(id, args)
  rvim._store[id](args)
end

---Create an autocommand
---@param name string
---@param commands Autocommand[]
function rvim.augroup(name, commands)
  vim.cmd("augroup " .. name)
  vim.cmd "autocmd!"
  for _, c in ipairs(commands) do
    local command = c.command
    if type(command) == "function" then
      local fn_id = rvim._create(command)
      command = fmt("lua rvim._execute(%s)", fn_id)
    end
    vim.cmd(
      string.format(
        "autocmd %s %s %s %s",
        table.concat(c.events, ","),
        table.concat(c.targets or {}, ","),
        table.concat(c.modifiers or {}, " "),
        command
      )
    )
  end
  vim.cmd "augroup END"
end

---Check if a cmd is executable
---@param e string
---@return boolean
function rvim.executable(e)
  return fn.executable(e) > 0
end

function rvim.echomsg(msg, hl)
  hl = hl or "Title"
  local msg_type = type(msg)
  if msg_type ~= "string" or "table" then
    return
  end
  if msg_type == "string" then
    msg = { { msg, hl } }
  end
  vim.api.nvim_echo(msg, true, {})
end

-- https://stackoverflow.com/questions/1283388/lua-merge-tables
function rvim.deep_merge(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k] or false) == "table") then
      rvim.deep_merge(t1[k], t2[k])
    else
      t1[k] = v
    end
  end
  return t1
end

---Check if directory exists using vim's isdirectory function
---@param path string
---@return boolean
function rvim.is_dir(path)
  return fn.isdirectory(path) > 0
end

---Check if a vim variable usually a number is truthy or not
---@param value integer
function rvim.truthy(value)
  assert(type(value) == "number", fmt("Value should be a number but you passed %s", value))
  return value > 0
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

---check if a mapping already exists
---@param lhs string
---@param mode string
---@return boolean
function rvim.has_map(lhs, mode)
  mode = mode or "n"
  return vim.fn.maparg(lhs, mode) ~= ""
end

---create a mapping function factory
---@param mode string
---@param o table
---@return fun(lhs: string, rhs: string, opts: table|nil) 'create a mapping'
local function make_mapper(mode, o)
  -- copy the opts table as extends will mutate the opts table passed in otherwise
  local parent_opts = vim.deepcopy(o)
  ---Create a mapping
  ---@param lhs string
  ---@param rhs string|function
  ---@param opts table
  return function(lhs, rhs, opts)
    -- assert(lhs ~= mode, fmt("The lhs should not be the same as mode for %s", lhs))
    assert(type(rhs) == "string" or type(rhs) == "function", '"rhs" should be a function or string')
    opts = opts and vim.deepcopy(opts) or {}

    local buffer = opts.buffer
    -- don't pass invalid keys to set keymap
    opts.buffer = nil
    -- add functions to a global table keyed by their index
    if type(rhs) == "function" then
      local fn_id = rvim._create(rhs)
      rhs = string.format("<cmd>lua rvim._execute(%s)<CR>", fn_id)
    end

    if buffer and type(buffer) == "number" then
      opts = vim.tbl_extend("keep", opts, parent_opts)
      api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, opts)
    elseif not buffer then
      api.nvim_set_keymap(mode, lhs, rhs, vim.tbl_extend("keep", opts, parent_opts))
    end
  end
end

rvim.make_mapper = make_mapper

local map_opts = { noremap = false, silent = true }
local noremap_opts = { noremap = true, silent = true }

rvim.map = make_mapper("", map_opts)
rvim.nmap = make_mapper("n", map_opts)
rvim.xmap = make_mapper("x", map_opts)
rvim.imap = make_mapper("i", map_opts)
rvim.vmap = make_mapper("v", map_opts)
rvim.omap = make_mapper("o", map_opts)
rvim.tmap = make_mapper("t", map_opts)
rvim.smap = make_mapper("s", map_opts)
rvim.cmap = make_mapper("c", { noremap = false, silent = false })

rvim.nnoremap = make_mapper("n", noremap_opts)
rvim.xnoremap = make_mapper("x", noremap_opts)
rvim.vnoremap = make_mapper("v", noremap_opts)
rvim.inoremap = make_mapper("i", noremap_opts)
rvim.onoremap = make_mapper("o", noremap_opts)
rvim.tnoremap = make_mapper("t", noremap_opts)
rvim.snoremap = make_mapper("s", noremap_opts)
rvim.cnoremap = make_mapper("c", { noremap = true, silent = false })

function rvim.command(args)
  local nargs = args.nargs or 0
  local name = args[1]
  local rhs = args[2]
  local types = (args.types and type(args.types) == "table") and table.concat(args.types, " ") or ""

  if type(rhs) == "function" then
    local fn_id = rvim._create(rhs)
    rhs = string.format("lua rvim._execute(%d%s)", fn_id, nargs > 0 and ", <f-args>" or "")
  end

  vim.cmd(string.format("command! -nargs=%s %s %s %s", nargs, types, name, rhs))
end

function rvim.invalidate(path, recursive)
  if recursive then
    for key, value in pairs(package.loaded) do
      if key ~= "_G" and value and vim.fn.match(key, path) ~= -1 then
        package.loaded[key] = nil
        require(key)
      end
    end
  else
    package.loaded[path] = nil
    require(path)
  end
end
