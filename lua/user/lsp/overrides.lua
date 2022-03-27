local M = {}

local lsp_manager = require "user.lsp.manager"

function M.setup(server_name)
  local already_configured = require("user.lsp.utils").is_client_active(server_name)
    or lsp_manager.client_is_configured(server_name)
  local config = lsp_manager.resolve_config(server_name)

  if already_configured then
    return
  end

  if server_name == "emmet_ls" then
    config = vim.tbl_deep_extend("force", config, {
      filetypes = {
        "html",
        "css",
        "typescriptreact",
        "typescript.tsx",
        "javascriptreact",
        "javascript.jsx",
      },
    })
  end

  require("lspconfig")[server_name].setup(config)
  lsp_manager.buf_try_add(server_name)
end

return M
