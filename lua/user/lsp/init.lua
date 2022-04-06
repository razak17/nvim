local M = {}
local Log = require "user.core.log"
local utils = require "user.utils.lsp"

local function lsp_hover_diagnostics()
  if not rvim.lsp.hover_diagnostics then
    return
  end

  utils.enable_lsp_hover_diagnostics()
end

local function lsp_highlight_document(client)
  if rvim.lsp.document_highlight == false then
    return
  end

  if client and client.resolved_capabilities.document_highlight then
    utils.enable_lsp_document_highlight(client.id)
  end
end

local function lsp_code_lens_refresh(client)
  if rvim.lsp.code_lens_refresh == false then
    return
  end

  if client and client.resolved_capabilities.code_lens then
    utils.enable_code_lens_refresh()
  end
end

local function lsp_setup_keymaps(client, bufnr)
  if client == nil then
    return
  end

  -- Remap using which_key
  local status_ok, wk = rvim.safe_require "which-key"
  if not status_ok then
    return
  end

  local maps = {
    n = {
      K = { vim.lsp.buf.hover, "lsp: hover" },
      gd = { vim.lsp.buf.definition, "lsp: definition" },
      gr = { vim.lsp.buf.references, "lsp: references" },
      gl = {
        "<cmd>lua require 'user.utils.lsp'.show_line_diagnostics()<CR>",
        "lsp: line diagnostics",
      },
    },
    x = {},
  }

  if client.resolved_capabilities.declaration then
    maps.n["ge"] = { vim.lsp.buf.declaration, "lsp: declaration" }
  end

  if client.resolved_capabilities.implementation then
    maps.n["gi"] = { vim.lsp.buf.implementation, "lsp: implementation" }
  end

  if client.resolved_capabilities.type_definition then
    maps.n["gT"] = { vim.lsp.buf.type_definition, "lsp: go to type definition" }
  end

  if client.supports_method "textDocument/prepareCallHierarchy" then
    maps.n["gI"] = { vim.lsp.buf.incoming_calls, "lsp: incoming calls" }
  end

  -- leader keymaps

  if client.supports_method "textDocument/rename" then
    maps.n["<leader>lr"] = { vim.lsp.buf.rename, "lsp: rename" }
  end

  maps.n["<leader>lp"] = {
    name = "+Peek",
    d = {
      "<cmd>lua require('user.lsp.peek').Peek('definition')<cr>",
      "peek: definition",
    },
    i = {
      "<cmd>lua require('user.lsp.peek').Peek('implementation')<cr>",
      "peek: implementation",
    },
    t = {
      "<cmd>lua require('user.lsp.peek').Peek('typeDefinition')<cr>",
      "peek: type definition",
    },
  }

  if client.supports_method "textDocument/formatting" then
    maps.n["<leader>lf"] = {
      "<cmd>LspFormat<cr>",
      "lsp: format",
    }
  end

  if client.supports_method "textDocument/publishDiagnostics" then
    maps.n["<leader>lj"] = {
      "<cmd>lua vim.diagnostic.goto_next()<cr>",
      "lsp: next diagnostic",
    }
    maps.n["<leader>lk"] = {
      "<cmd>lua vim.diagnostic.goto_prev()<cr>",
      "lsp: prev diagnostic",
    }
    maps.n["<leader>lL"] = {
      "<cmd>lua vim.diagnostic.setloclist()<cr>",
      "lsp: set loclist",
    }
  end

  if client.supports_method "textDocument/codeLens" then
    maps.n["<leader>lc"] = { "<cmd>lua vim.lsp.codelens.run()<cr>", "lsp: codelens action" }
  end

  for mode, value in pairs(maps) do
    wk.register(value, { buffer = bufnr, mode = mode })
  end
end

local function lsp_setup_tagfunc(client, bufnr)
  if not client.resolved_capabilities.goto_definition then
    return
  end
  vim.bo[bufnr].tagfunc = "v:lua.rvim.lsp.tagfunc"
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

  lsp_highlight_document(client)
  lsp_code_lens_refresh(client)
  lsp_hover_diagnostics()
  lsp_setup_keymaps(client, bufnr)
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

  local formatting = require "user.lsp.formatting"

  formatting.configure_format_on_save()

  formatting.configure_format_on_focus_lost()
end

return M
