local M = {}
local Log = require "user.core.log"
local fmt = string.format

local function get_format(defaults)
  -- accept a basic boolean `rvim.util.format_on_save=true`
  if type(defaults) ~= "table" then
    return defaults
  end

  return {
    pattern = rvim.util.format_on_save.pattern or defaults.pattern,
    timeout = rvim.util.format_on_save.timeout or defaults.timeout,
  }
end

local get_format_on_save_opts = function(defaults)
  return get_format(defaults)
end

local get_format_on_focus_lost_opts = function(defaults)
  return get_format(defaults)
end

local function enable_format(name, opts)
  rvim.augroup("FormatOnSave", {
    {
      event = { "BufWritePre" },
      pattern = { opts.pattern },
      command = function()
        require("user.utils.lsp").format { timeout_ms = opts.timeout, filter = opts.filter }
      end,
    },
  })
  Log:debug(fmt("enabled %s", name))
end

function M.enable_format_on_save()
  local defaults = rvim.util.format_on_save
  local opts = get_format_on_save_opts(defaults)
  enable_format("FormatOnSave", opts)
end

function M.enable_format_on_focus_lost()
  local defaults = rvim.util.format_on_focus_lost
  local opts = get_format_on_focus_lost_opts(defaults)
  enable_format("FormatOnFocusLost", opts)
end

local function disable_format(name)
  rvim.disable_augroup(name)
  Log:debug(fmt("disabled %s", name))
end

function M.disable_format_on_save()
  disable_format "FormatOnSave"
end

function M.disable_format_on_focus_lost()
  disable_format "FormatOnFocusLost"
end

---@param cond table
---@param name string
---@param event string
local function configure_format(cond, name, event)
  if cond then
    if vim.fn.exists(fmt("#%s#%s", name, event)) == 1 then
      rvim.disable_augroup(name)
      Log:debug(fmt("reloading %s configuration", name))
    end
    if name == "FormatOnSave" then
      M.enable_format_on_save()
    elseif name == "FormatOnFocusLost" then
      M.enable_format_on_focus_lost()
    end
  else
    if name == "FormatOnSave" then
      M.disable_format_on_save()
    elseif name == "FormatOnFocusLost" then
      M.disable_format_on_focus_lost()
    end
  end
end

function M.configure_format_on_save()
  local name = "FormatOnSave"
  local cond = rvim.util.format_on_save
  configure_format(cond, name, "BufWritePre")
end

function M.configure_format_on_focus_lost()
  -- local name = "FormatOnFocusLost"
  -- local cond = rvim.util.format_on_focus_lost
  -- configure_format(cond, name, "FocusLost")
  if rvim.util.format_on_focus_lost then
    if vim.fn.exists "#FormatOnFocusLost#FocusLost" == 1 then
      rvim.disable_augroup "FormatOnFocusLost"
      Log:debug "reloading FormatOnFocusLost configuration"
    end
    M.enable_format_on_focus_lost()
  else
    M.disable_format_on_focus_lost()
  end
end

function M.toggle_format_on_save()
  if vim.fn.exists "#format_on_save#BufWritePre" == 0 then
    M.enable_format_on_save()
  else
    M.disable_format_on_save()
  end
end

return M
