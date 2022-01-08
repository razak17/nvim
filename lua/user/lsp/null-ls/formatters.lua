local M = {}

local Log = require "user.core.log"

local null_ls = require "null-ls"
local services = require "user.lsp.null-ls.services"
local method = null_ls.methods.FORMATTING

function M.list_registered_providers(filetype)
  local registered_providers = services.list_registered_providers_names(filetype)
  return registered_providers[method] or {}
end

function M.list_available(filetype)
  local formatters = {}
  local tbl = require "utils.table"
  for _, provider in pairs(null_ls.builtins.formatting) do
    if
      tbl.contains(provider.filetypes or {}, function(ft)
        return ft == "*" or ft == filetype
      end)
    then
      table.insert(formatters, provider.name)
    end
  end

  table.sort(formatters)
  return formatters
end

function M.setup(formatter_configs)
  if vim.tbl_isempty(formatter_configs) then
    return
  end

  local registered = services.register_sources(formatter_configs, method)

  if #registered > 0 then
    Log:debug("Registered the following formatters: " .. unpack(registered))
  end
end

return M
