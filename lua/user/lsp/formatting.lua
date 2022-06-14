local M = {}
local Log = require("user.core.log")
local fmt = string.format

local save_name = "FormatOnSave"
local focus_name = "FormatOnFocusLost"
local format_on_save = rvim.util.format_on_save
local format_on_focus_lost = rvim.util.format_on_focus_lost

local function get_format(defaults)
  if type(defaults) == "table" then
    return defaults
  end

  if defaults == true then
    return {
      pattern = format_on_save.pattern,
      timeout = format_on_save.timeout,
    }
  end
end

local function enable_format(name, defaults, event)
  local opts = get_format(defaults)
  rvim.augroup(name, {
    {
      event = { event },
      pattern = { opts.pattern },
      command = function()
        if rvim.find_string(rvim.lsp.format_on_save_exclusions, vim.bo.ft) then
          return
        end
        require("user.utils.lsp").format({ timeout_ms = opts.timeout, filter = opts.filter })
      end,
    },
  })
  Log:debug(fmt("enabled %s", name))
end

local function disable_format(name)
  pcall(vim.api.nvim_del_augroup_by_name, name)
  Log:debug(fmt("disabled %s", name))
end

---@param cond table
---@param name string
---@param event string
local function configure_format(cond, name, event)
  if cond then
    if vim.fn.exists(fmt("#%s#%s", name, event)) == 1 then
      pcall(vim.api.nvim_del_augroup_by_name, name)
      Log:debug(fmt("reloading %s configuration", name))
    end
    if name == save_name then
      enable_format(save_name, format_on_save, event)
    elseif name == focus_name then
      enable_format(focus_name, format_on_focus_lost, event)
    end
  else
    disable_format(name)
  end
end

function M.configure_format_on_save()
  local name = save_name
  local event = "BufWritePre"
  configure_format(format_on_save, name, event)
end

function M.configure_format_on_focus_lost()
  local name = focus_name
  local event = "FocusLost"
  configure_format(format_on_focus_lost, name, event)
end

return M
