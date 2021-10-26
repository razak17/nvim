local Log = require "core.log"
local tbl = require "utils.table"

local M = {}

-- function M.is_client_active(name)
--   local clients = vim.lsp.get_active_clients()
--   for _, client in pairs(clients) do
--     if client.name == name then
--       return true, client
--     end
--   end
--   return false
-- end

function M.is_client_active(name)
  local clients = vim.lsp.get_active_clients()
  return tbl.find_first(clients, function(client)
    return client.name == name
  end)
end

function M.toggle_autoformat()
  if rvim.common.format_on_save then
    rvim.augroup("AutoFormatOnSaVe", {
      {
        events = { "BufWritePre" },
        targets = { "*" },
        command = ":silent lua vim.lsp.buf.formatting_sync()",
      },
    })
    Log:debug "Format on save active"
  end

  if not rvim.common.format_on_save then
    vim.cmd [[
      if exists('#autoformat#BufWritePre')
        :autocmd! autoformat
      endif
    ]]
    Log:debug "Format on save off"
  end
end

return M
