local M = {}
local Log = require("user.core.log")

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

function M.global_on_init(client, bufnr)
  if rvim.lsp.on_init_callback then
    rvim.lsp.on_init_callback(client, bufnr)
    Log:debug("Called lsp.on_init_callback")
    return
  end
end

function M.get_global_opts()
  return {
    on_attach = rvim.lsp.on_attach,
    on_init = M.global_on_init,
    capabilities = M.global_capabilities(),
  }
end

function M.setup()
  Log:debug("Setting up LSP support")

  local lsp_status_ok, _ = rvim.safe_require("lspconfig")
  if not lsp_status_ok then
    return
  end

  local nlsp_status_ok, lsp_settings = rvim.safe_require("nlspsettings")
  if nlsp_status_ok then
    lsp_settings.setup({
      config_home = join_paths(rvim.get_user_dir(), "lsp", "lsp-settings"),
      append_default_schemas = true,
    })
  end

  require("nvim-lsp-installer").setup(rvim.lsp.installer.setup)
  require("user.lsp.null-ls").setup()
end

return M
