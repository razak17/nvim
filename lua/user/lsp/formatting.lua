local M = {}
local Log = require "user.core.log"

local get_format_on_save_opts = function()
  local defaults = rvim.util.format_on_save
  -- accept a basic boolean `rvim.util.format_on_save=true`
  if type(rvim.util.format_on_save) ~= "table" then
    return defaults
  end

  return {
    pattern = rvim.util.format_on_save.pattern or defaults.pattern,
    timeout = rvim.util.format_on_save.timeout or defaults.timeout,
  }
end

local get_format_on_focus_lost_opts = function()
  local defaults = rvim.util.format_on_focus_lost
  -- accept a basic boolean `rvim.util.format_on_focus_lost=true`
  if type(rvim.util.format_on_focus_lost) ~= "table" then
    return defaults
  end

  return {
    pattern = rvim.util.format_on_focus_lost.pattern or defaults.pattern,
    timeout = rvim.util.format_on_focus_lost.timeout or defaults.timeout,
  }
end

function M.enable_format_on_save()
  local opts = get_format_on_save_opts()
  rvim.augroup("FormatOnSave", {
    {
      event = { "BufWritePre" },
      pattern = { opts.pattern },
      command = function()
        require("user.utils.lsp").format { timeout_ms = opts.timeout, filter = opts.filter }
      end,
    },
  })
  Log:debug "enabled format-on-save"
end

function M.enable_format_on_focus_lost()
  local opts = get_format_on_focus_lost_opts()
  rvim.augroup("FormatOnFocusLost", {
    {
      event = { "FocusLost" },
      pattern = { opts.pattern },
      command = function()
        require("user.utils.lsp").format { timeout_ms = opts.timeout, filter = opts.filter }
      end,
    },
  })
  Log:debug "enabled format-on-focus-lost"
end

function M.disable_format_on_save()
  rvim.disable_augroup "format_on_save"
  Log:debug "disabled format-on-save"
end

function M.configure_format_on_save()
  if rvim.util.format_on_save then
    if vim.fn.exists "#format_on_save#BufWritePre" == 1 then
      rvim.disable_augroup "FormatOnSave"
      Log:debug "reloading format-on-save configuration"
    end
    M.enable_format_on_save()
  else
    M.disable_format_on_save()
  end
end

function M.disable_format_on_focus_lost()
  rvim.disable_augroup "format_on_focus_lost"
  Log:debug "disabled format-on-focus-lost"
end

function M.configure_format_on_focus_lost()
  if rvim.util.format_on_focus_lost then
    if vim.fn.exists "#format_on_focus_lost#FocusLost" == 1 then
      rvim.disable_augroup "FormatOnFocusLost"
      Log:debug "reloading format-on-focus-lost configuration"
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
