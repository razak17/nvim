local Log = {}

--- Adds a log entry using Plenary.log
---@param msg any
---@param level string [same as vim.log.log_levels]
function Log:add_entry(msg, level)
  assert(type(level) == "string")
  if self.__handle then
    -- plenary uses lower-case log levels
    self.__handle[level:lower()](msg)
    return
  end
  local status_ok, plenary = pcall(require, "plenary")
  if status_ok then
    local default_opts = { plugin = "rvim", level = rvim.log.level }
    local handle = plenary.log.new(default_opts)
    handle[level:lower()](msg)
    self.__handle = handle
  end
  -- don't do anything if plenary is not available
end

--- Creates or retrieves a log handle for the default logfile
--- based on Plenary.log
---@return log handle
function Log:get_default()
  return Log:new { plugin = "rvim", level = rvim.log.level }
end

--- Creates a log handle based on Plenary.log
---@param opts these are passed verbatim to Plenary.log
---@return log handle
function Log:new(opts)
  local status_ok, _ = pcall(require, "plenary.log")
  if not status_ok then
    return nil
  end

  local obj = require("plenary.log").new(opts)
  local path = string.format("%s/%s.log", vim.api.nvim_call_function("stdpath", { "cache" }), opts.plugin)

  obj.get_path = function()
    return path
  end

  return obj
end

---Retrieves the path of the logfile
---@return string path of the logfile
function Log:get_path()
  return string.format("%s/%s.log", vim.fn.stdpath "cache", "lunarvim")
end

---Add a log entry at TRACE level
---@param msg any
function Log:trace(msg)
  self:add_entry(msg, "TRACE")
end

---Add a log entry at DEBUG level
---@param msg any
function Log:debug(msg)
  self:add_entry(msg, "DEBUG")
end

---Add a log entry at INFO level
---@param msg any
function Log:info(msg)
  self:add_entry(msg, "INFO")
end

---Add a log entry at WARN level
---@param msg any
function Log:warn(msg)
  self:add_entry(msg, "WARN")
end

---Add a log entry at ERROR level
---@param msg any
function Log:error(msg)
  self:add_entry(msg, "ERROR")
end

setmetatable({}, Log)

return Log
