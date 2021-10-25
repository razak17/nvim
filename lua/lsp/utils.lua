local M = {}
local Log = require "core.log"

function M.is_client_active(name)
  local clients = vim.lsp.get_active_clients()
  for _, client in pairs(clients) do
    if client.name == name then
      return true, client
    end
  end
  return false
end

function M.toggle_autoformat()
  if rvim.common.format_on_save then
    rvim.augroup("AutoFormatOnSaVE", {
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
