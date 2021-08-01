local lspconfig = require "lspconfig"
local u = require "lsp.utils"

local M = {}

local function lsp_highlight_document(client)
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

local global_capabilities = vim.lsp.protocol.make_client_capabilities()
global_capabilities.textDocument.completion.completionItem.snippetSupport = true
global_capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" },
}
global_capabilities.textDocument.codeAction = {
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

local function global_on_init(client, bufnr)
  if rvim.lsp.on_init_callback then
    rvim.lsp.on_init_callback(client, bufnr)
  end

  local formatters = rvim.lang[vim.bo.filetype].formatters
  if not vim.tbl_isempty(formatters) then
    client.resolved_capabilities.document_formatting = false
    u.lvim_log(string.format("Overriding [%s] formatter with [%s]", client.name, formatters[1].exe))
  end
end

lspconfig.util.default_config = vim.tbl_extend(
  "force",
  lspconfig.util.default_config,
  { capabilities = global_capabilities, on_init = global_on_init }
)

function M.on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  lsp_highlight_document(client)
  require("lsp.null-ls").setup(vim.bo.filetype)
end

function M.setup(lang)
  local lsp = rvim.lang[lang].lsp
  if require("lsp.utils").check_lsp_client_active(lsp.provider) then
    return
  end

  lspconfig[lsp.provider].setup(lsp.setup)
end

return M
