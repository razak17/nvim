local M = {}
local Log = require "user.core.log"
local utils = require "user.utils.lsp"
local keymaps = require "user.lsp.keymaps"

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
    Log:debug "Called lsp.on_init_callback"
    return
  end
end

function M.global_on_attach(client, bufnr)
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  if rvim.lsp.document_highlight then
    utils.enable_lsp_document_highlight(client, bufnr)
    utils.lsp_document_highlight(client)
  end

  if rvim.lsp.code_lens_refresh then
    utils.enable_code_lens_refresh(client, bufnr)
  end

  if rvim.lsp.hover_diagnostics then
    utils.enable_lsp_hover_diagnostics(bufnr)
  end

  keymaps.init(client)
  utils.enable_lsp_setup_tagfunc(client, bufnr)
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

  require("nvim-lsp-installer").setup {
    -- use the default nvim_data_dir, since the server binaries are independent
    install_root_dir = join_paths(vim.call("stdpath", "data"), "lsp_servers"),
  }

  require("user.lsp.null-ls").setup()

  local formatting = require "user.lsp.formatting"

  formatting.configure_format_on_save()

  formatting.configure_format_on_focus_lost()
end

return M
