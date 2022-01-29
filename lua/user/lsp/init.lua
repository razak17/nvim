local M = {}
local Log = require "user.core.log"
local utils = require "user.utils"
local autocmds = require "user.lsp.autocmds"

local function lsp_hover_diagnostics()
  if not rvim.lsp.hover_diagnostics then
    return
  end

  autocmds.enable_lsp_hover_diagnostics()
end

local function lsp_highlight_document(client)
  if rvim.lsp.document_highlight == false then
    return
  end

  if client and client.resolved_capabilities.document_highlight then
    autocmds.enable_lsp_document_highlight(client.id)
  end
end

local function lsp_code_lens_refresh(client)
  if rvim.lsp.code_lens_refresh == false then
    return
  end

  if client and client.resolved_capabilities.code_lens then
    autocmds.enable_code_lens_refresh()
  end
end

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

  local status_ok, cmp_nvim_lsp = rvim.safe_require "cmp_nvim_lsp"
  if status_ok then
    capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
  end

  return capabilities
end

local function select_default_formater(client)
  if client.name == "null-ls" or not client.resolved_capabilities.document_formatting then
    return
  end

  if client.name == "tsserver" then
    client.resolved_capabilities.document_formatting = false
  end

  Log:debug("Checking for formatter overriding for " .. client.name)
  local formatters = require "lsp.null-ls.formatters"
  local client_filetypes = client.config.filetypes or {}
  for _, filetype in ipairs(client_filetypes) do
    if #vim.tbl_keys(formatters.list_registered(filetype)) > 0 then
      Log:debug(
        "Formatter overriding detected. Disabling formatting capabilities for " .. client.name
      )
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
    end
  end
end

function M.global_on_exit(_, _)
  if rvim.lsp.document_highlight then
    autocmds.disable_lsp_document_highlight()
  end

  if rvim.lsp.code_lens_refresh then
    autocmds.disable_code_lens_refresh()
  end
end

function M.global_on_init(client, bufnr)
  select_default_formater(client)
end

function M.global_on_attach(client, bufnr)
  lsp_highlight_document(client)
  lsp_code_lens_refresh(client)
  lsp_hover_diagnostics()
  require("user.lsp.binds"):init(client)
end

local function bootstrap_nlsp(opts)
  opts = opts or {}
  local lsp_settings_status_ok, lsp_settings = rvim.safe_require "nlspsettings"
  if lsp_settings_status_ok then
    lsp_settings.setup(opts)
  end
end

function M.get_global_opts()
  return {
    on_attach = M.global_on_attach,
    on_init = M.global_on_init,
    capabilities = M.global_capabilities(),
  }
end

function M.setup()
  Log:debug "Setting up LSP support"

  local lsp_status_ok, _ = rvim.safe_require "lspconfig"
  if not lsp_status_ok then
    return
  end

  bootstrap_nlsp { config_home = utils.join_paths(rvim.get_config_dir(), "external/nlsp-settings") }

  require("user.lsp.null-ls").setup()

  autocmds.configure_format_on_save()
end

return M
