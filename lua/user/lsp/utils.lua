local Log = require "user.core.log"
local tbl = require "user.utils.table"

local M = {}

function M.is_client_active(name)
  local clients = vim.lsp.get_active_clients()
  return tbl.find_first(clients, function(client)
    return client.name == name
  end)
end

---Get all supported filetypes by nvim-lsp-installer
---@return table supported filestypes as a list of strings
function M.get_all_supported_filetypes()
  local status_ok, lsp_installer_filetypes = pcall(
    require,
    "nvim-lsp-installer._generated.filetype_map"
  )
  if not status_ok then
    return {}
  end
  return vim.tbl_keys(lsp_installer_filetypes or {})
end

function M.conditional_document_highlight(id)
  local client_ok, method_supported = pcall(function()
    return vim.lsp.get_client_by_id(id).resolved_capabilities.document_highlight
  end)
  if not client_ok or not method_supported then
    return
  end
  vim.lsp.buf.document_highlight()
end

return M
