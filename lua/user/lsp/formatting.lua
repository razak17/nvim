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

function M.enable_format_on_save(opts)
  local fmd_cmd = string.format(":silent lua vim.lsp.buf.formatting_sync({}, %s)", opts.timeout_ms)
  rvim.augroup("FormatOnSave", {
    {
      event = { "BufWritePre" },
      pattern = { opts.pattern },
      command = fmd_cmd,
    },
  })
  Log:debug "enabled format-on-save"
end

function M.enable_format_on_focus_lost(opts)
  local fmd_cmd = string.format(":silent lua vim.lsp.buf.formatting_sync({}, %s)", opts.timeout_ms)
  rvim.augroup("FormatOnFocusLost", {
    {
      event = { "FocusLost" },
      pattern = { opts.pattern },
      command = fmd_cmd,
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
      rvim.disable_augroup "format_on_save"
      Log:debug "reloading format-on-save configuration"
    end
    local opts = get_format_on_save_opts()
    M.enable_format_on_save(opts)
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
      rvim.disable_augroup "format_on_focus_lost"
      Log:debug "reloading format-on-focus-lost configuration"
    end
    local opts = get_format_on_focus_lost_opts()
    M.enable_format_on_focus_lost(opts)
  else
    M.disable_format_on_focus_lost()
  end
end

function M.toggle_format_on_save()
  if vim.fn.exists "#format_on_save#BufWritePre" == 0 then
    local opts = get_format_on_save_opts()
    M.enable_format_on_save(opts)
  else
    M.disable_format_on_save()
  end
end

return M
