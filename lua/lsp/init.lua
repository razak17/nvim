local command = rvim.command

local M = {}

local function lsp_highlight_document(client)
  if rvim.lsp.document_highlight == false then
    return -- we don't need further
  end
  -- Set autocommands conditional on server_capabilities
  if client and client.resolved_capabilities.document_highlight then
    rvim.augroup("LspCursorCommands", {
      {
        events = { "CursorHold" },
        targets = { "<buffer>" },
        command = "lua vim.lsp.buf.document_highlight()",
      },
      {
        events = { "CursorHoldI" },
        targets = { "<buffer>" },
        command = "lua vim.lsp.buf.document_highlight()",
      },
      {
        events = { "CursorMoved" },
        targets = { "<buffer>" },
        command = "lua vim.lsp.buf.clear_references()",
      },
    })
  end
end

local function lsp_code_lens_refresh(client)
  if rvim.lsp.code_lens_refresh == false then
    return
  end

  if client.resolved_capabilities.code_lens then
    rvim.augroup("LspCodeLensRefresh", {
      {
        events = { "InsertLeave" },
        targets = { "<buffer>" },
        command = "lua vim.lsp.codelens.refresh()",
      },
      {
        events = { "InsertLeave" },
        targets = { "<buffer>" },
        command = "lua vim.lsp.codelens.display()",
      },
    })
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
  return capabilities
end

function M.global_on_init(client, bufnr)
  local formatters = rvim.lang[vim.bo.filetype].formatters
  if not vim.tbl_isempty(formatters) and formatters[1]["exe"] ~= nil and formatters[1].exe ~= "" then
    client.resolved_capabilities.document_formatting = false
  end
end

function M.global_on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  lsp_highlight_document(client)
  lsp_code_lens_refresh(client)
  require("lsp.binds").setup(client)
  require("lsp.null-ls").setup(vim.bo.filetype)
end

function M.setup(lang)
  local lsp_status_ok, lspconfig = pcall(require, "lspconfig")
  local lsp_utils = require "lsp.utils"
  local lsp = rvim.lang[lang].lsp

  if not lsp_status_ok or lsp_utils.is_client_active(lsp.provider) then
    return
  end

  if lsp.provider ~= nil and lsp.provider ~= "" then
    if not lsp.setup.on_attach then
      lsp.setup.on_attach = M.global_on_attach
    end
    if not lsp.setup.on_init then
      lsp.setup.on_init = M.global_on_init
    end
    if not lsp.setup.capabilities then
      lsp.setup.capabilities = M.global_capabilities()
    end
    lspconfig[lsp.provider].setup(lsp.setup)
  end
end

return M
