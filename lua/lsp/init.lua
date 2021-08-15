local lspconfig = require "lspconfig"
local Log = require "core.log"

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
  local formatters = rvim.lang[vim.bo.filetype].formatters
  if not vim.tbl_isempty(formatters) and formatters[1]["exe"] ~= nil and formatters[1].exe ~= "" then
    client.resolved_capabilities.document_formatting = false
    Log:get_default().info(
      string.format("Overriding language server [%s] with format provider [%s]", client.name, formatters[1].exe)
    )
  end
end


local function set_smart_cwd(client)
  local proj_dir = client.config.root_dir
  if rvim.lsp.smart_cwd and proj_dir ~= "/" then
    vim.api.nvim_set_current_dir(proj_dir)
    _G.change_tree_dir(proj_dir)
  end
end

function M.on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  lsp_highlight_document(client)
  require("lsp.binds").setup(client)
  set_smart_cwd(client)
  require("lsp.null-ls").setup(vim.bo.filetype)
end

function M.setup(lang)
  lspconfig.util.default_config = vim.tbl_extend(
    "force",
    lspconfig.util.default_config,
    { capabilities = global_capabilities, on_init = global_on_init }
  )

  local lsp_utils = require "lsp.utils"
  local lsp = rvim.lang[lang].lsp
  if lsp_utils.is_client_active(lsp.provider) then
    return
  end

  lspconfig[lsp.provider].setup(lsp.setup)
end

return M
