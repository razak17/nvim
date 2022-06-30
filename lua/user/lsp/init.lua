local Log = require("user.core.log")
local fn = vim.fn

local M = {}

local function setup_capabilities()
  local snippet = {
    properties = { "documentation", "detail", "additionalTextEdits" },
  }
  local code_action = {
    dynamicRegistration = false,
    codeActionLiteralSupport = {
      codeActionKind = {
        valueSet = (function()
          local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
          table.sort(res)
          return res
        end)(),
      },
    },
  }
  local fold = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  return snippet, code_action, fold
end

function M.global_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local snippet_support, code_action_support, folding_range_support = setup_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = snippet_support
  capabilities.textDocument.codeAction = code_action_support
  capabilities.textDocument.foldingRange = folding_range_support
  local ok, cmp_nvim_lsp = rvim.safe_require("cmp_nvim_lsp")
  if ok then
    cmp_nvim_lsp.update_capabilities(capabilities)
  end

  return capabilities
end

-- This function allows reading a per project "settings.json" file in the `.vim` directory of the project.
---@param client table<string, any>
---@return boolean
function rvim.lsp.on_init(client)
  local path = client.workspace_folders[1].name
  local config_path = path .. "/.vim/settings.json"
  if fn.filereadable(config_path) == 0 then
    return true
  end
  local ok, json = pcall(fn.readfile, config_path)
  if not ok then
    return
  end
  local overrides = vim.json.decode(table.concat(json, "\n"))
  for name, config in pairs(overrides) do
    if name == client.name then
      local original = client.config
      client.config = vim.tbl_deep_extend("force", original, config)
      client.notify("workspace/didChangeConfiguration")
    end
  end
  return true
end

function M.get_global_opts()
  return {
    on_attach = rvim.lsp.on_attach,
    on_init = rvim.lsp.on_init,
    capabilities = M.global_capabilities(),
  }
end

function M.setup()
  Log:debug("Setting up LSP support")

  local lsp_status_ok, _ = rvim.safe_require("lspconfig")
  if not lsp_status_ok then
    return
  end

  pcall(function()
    require("nlspsettings").setup(rvim.lsp.nlsp_settings.setup)
  end)

  pcall(function()
    require("nvim-lsp-installer").setup(rvim.lsp.installer.setup)
  end)

  require("user.lsp.null-ls").setup()
end

return M
