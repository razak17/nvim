local M = {}

function M.check_lsp_client_active(name)
  local clients = vim.lsp.get_active_clients()
  for _, client in pairs(clients) do
    if client.name == name then
      return true
    end
  end
  return false
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

function M.lvim_log(msg)
  if rvim.common.debug then
    vim.notify(msg, vim.log.levels.DEBUG)
  end
end

return M
