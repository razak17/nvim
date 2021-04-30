local lsp_utils = require 'modules.lsp.lspconfig.utils'
local M = {}

local on_init = function(client)
  client.config.flags = {}
  if client.config.flags then
    client.config.flags.allow_incremental_sync = true
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport =
    {properties = {'documentation', 'detail', 'additionalTextEdits'}}
capabilities.textDocument.codeAction = {
  dynamicRegistration = false,
  codeActionLiteralSupport = {
    codeActionKind = {
      valueSet = (function()
        local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
        table.sort(res)
        return res
      end)()
    }
  }
}

local enhance_attach = function(client, bufnr)
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  lsp_utils.lsp_saga(bufnr)
  lsp_utils.lsp_highlight_cmds()
  lsp_utils.lsp_line_diagnostics()
  lsp_utils.lsp_mappings(bufnr)
  lsp_utils.lsp_document_formatting(client)
  lsp_utils.lsp_document_highlight(client)
end

local function lsp_setup()
  require 'modules.lsp.servers.bash'
  require 'modules.lsp.servers.clangd'
  require 'modules.lsp.servers.elixir'
  require 'modules.lsp.servers.go'
  require 'modules.lsp.servers.python'
  require 'modules.lsp.servers.rust'
  require 'modules.lsp.servers.sumneko_lua'
  require 'modules.lsp.servers.tsserver'
  require 'modules.lsp.servers.simple_lsp'
  require 'modules.lsp.servers.efm'
end

M.enhance_attach = enhance_attach
M.capabilities = capabilities
M.on_init = on_init
M.setup = lsp_setup

return M
