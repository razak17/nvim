local M = {}

local Log = require "user.core.log"

local null_ls = require "null-ls"
local services = require "user.lsp.null-ls.services"
local method = null_ls.methods.DIAGNOSTICS

function M.list_registered_providers(filetype)
  local registered_providers = services.list_registered_providers_names(filetype)
  return registered_providers[method] or {}
end

function M.list_available(filetype)
  local linters = {}
  local tbl = require "user.utils.table"
  for _, provider in pairs(null_ls.builtins.diagnostics) do
    if
      tbl.contains(provider.filetypes or {}, function(ft)
        return ft == "*" or ft == filetype
      end)
    then
      table.insert(linters, provider.name)
    end
  end

  table.sort(linters)
  return linters
end

function M.setup(linter_configs)
  if vim.tbl_isempty(linter_configs) then
    return
  end

  local registered = services.register_sources(linter_configs, method)

  if #registered > 0 then
    Log:debug("Registered the following linters: " .. unpack(registered))
  end
end

return M
