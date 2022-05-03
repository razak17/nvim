local M = {}
local Log = require "user.core.log"
local utils = require "user.utils.lsp"
local keymaps = require "user.lsp.keymaps"

local function lsp_hover_diagnostics(bufnr)
  if not rvim.lsp.hover_diagnostics then
    return
  end

  utils.enable_lsp_hover_diagnostics(bufnr)
end

local function lsp_highlight_document(client, bufnr)
  if rvim.lsp.document_highlight == false then
    return
  end

  if client and client.resolved_capabilities.document_highlight then
    utils.enable_lsp_document_highlight(client.id, bufnr)
  end
end

local function lsp_code_lens_refresh(client, bufnr)
  if rvim.lsp.code_lens_refresh == false then
    return
  end

  if client and client.resolved_capabilities.code_lens then
    utils.enable_code_lens_refresh(bufnr)
  end
end

local function lsp_setup_tagfunc(client, bufnr)
  if
    not client.resolved_capabilities.goto_definition
    or not client.resolved_capabilities.document_formatting
  then
    return
  end

  vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
  vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"
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

  local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if status_ok then
    capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
  end

  return capabilities
end

local function select_default_formater(client)
  if client.name == "null-ls" or not client.resolved_capabilities.document_formatting then
    return
  end

  for _, server in ipairs(rvim.lsp.formatting_ignore_list) do
    if client.name == server then
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
    end
  end

  Log:debug("Checking for formatter overriding for " .. client.name)
  local formatters = require "user.lsp.null-ls.formatters"
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
    utils.disable_lsp_document_highlight()
  end

  if rvim.lsp.code_lens_refresh then
    utils.disable_code_lens_refresh()
  end
end

function M.global_on_init(client, bufnr)
  select_default_formater(client)
end

function M.global_on_attach(client, bufnr)
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end
  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  lsp_highlight_document(client, bufnr)
  lsp_code_lens_refresh(client, bufnr)
  lsp_hover_diagnostics(bufnr)
  keymaps.init(client, bufnr)
  lsp_setup_tagfunc(client, bufnr)
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

  bootstrap_nlsp {
    config_home = join_paths(rvim.get_user_dir(), "lsp", "lsp-settings"),
    append_default_schemas = true,
  }

  require("user.lsp.null-ls").setup()

  require("nvim-lsp-installer").setup {
    -- use the default nvim_data_dir, since the server binaries are independent
    install_root_dir = join_paths(vim.call("stdpath", "data"), "lsp_servers"),
  }

  local formatting = require "user.lsp.formatting"

  formatting.configure_format_on_save()

  formatting.configure_format_on_focus_lost()
end

return M
