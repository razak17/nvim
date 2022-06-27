local M = {}
local Log = require("user.core.log")

function M.global_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
  }
  capabilities.textDocument.codeAction = {
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

  local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if status_ok then
    capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
  end

  return capabilities
end

function M.global_on_exit(_, _)
  if rvim.lsp.document_highlight then
    pcall(vim.api.nvim_del_augroup_by_name, "LspCursorCommands")
  end

  if rvim.lsp.code_lens_refresh then
    pcall(vim.api.nvim_del_augroup_by_name, "LspCodeLensRefresh")
  end
end

function M.global_on_init(client, bufnr)
  if rvim.lsp.on_init_callback then
    rvim.lsp.on_init_callback(client, bufnr)
    Log:debug("Called lsp.on_init_callback")
    return
  end
end

local function bootstrap_nlsp(opts)
  opts = opts or {}
  local lsp_settings_status_ok, lsp_settings = rvim.safe_require("nlspsettings")
  if lsp_settings_status_ok then
    lsp_settings.setup(opts)
  end
end

function M.get_global_opts()
  return {
    on_attach = rvim.lsp.on_attach,
    on_init = M.global_on_init,
    on_exit = M.common_on_exit,
    capabilities = M.global_capabilities(),
  }
end

function M.setup()
  Log:debug("Setting up LSP support")

  local lsp_status_ok, _ = rvim.safe_require("lspconfig")
  if not lsp_status_ok then
    return
  end

  bootstrap_nlsp({
    config_home = join_paths(rvim.get_user_dir(), "lsp", "lsp-settings"),
    append_default_schemas = true,
  })

  require("nvim-lsp-installer").setup(rvim.lsp.installer.setup)

  require("user.lsp.null-ls").setup()
end

return M
