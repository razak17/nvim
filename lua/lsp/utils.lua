local M = {}

function M.is_client_active(name)
  local clients = vim.lsp.get_active_clients()
  for _, client in pairs(clients) do
    if client.name == name then
      return true
    end
  end
  return false
end

function M.get_active_client_by_ft(filetype)
  if not rvim.lang[filetype] or not rvim.lang[filetype].lsp then
    return nil
  end

  local clients = vim.lsp.get_active_clients()
  for _, client in pairs(clients) do
    if client.name == rvim.lang[filetype].lsp.provider then
      return client
    end
  end
  return nil
end

function M.lspLocList()
  rvim.augroup("LspLocationList", {
    {
      events = { "User LspDiagnosticsChanged" },
      command = function()
        vim.lsp.diagnostic.set_loclist {
          workspace = true,
          severity_limit = "Warning",
          open_loclist = false,
        }
      end,
    },
  })
end

function M.toggle_autoformat()
  if rvim.common.format_on_save then
    rvim.augroup("AutoFormatOnSaVE", {
      {
        events = { "BufWritePre" },
        targets = { "*" },
        command = ":silent lua vim.lsp.buf.formatting_sync(nil, 1000)",
      },
    })
  end

  if not rvim.common.format_on_save then
    vim.cmd [[
      if exists('#autoformat#BufWritePre')
        :autocmd! autoformat
      endif
    ]]
  end
end

function M.root_dir()
  local util = require "lspconfig.util"
  return util.root_pattern(".gitignore", ".git", vim.fn.getcwd())
end

return M
