local r17 = _G.r17
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

vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      underline = true,
      virtual_text = false,
      signs = true,
      update_in_insert = false
    })

-- NOTE: the hover handler returns the bufnr,winnr so can be use for mappings
vim.lsp.handlers["textDocument/hover"] =
    vim.lsp.with(vim.lsp.handlers.hover, {border = "single"})

local enhance_attach = function(client, bufnr)
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  r17.lsp.saga(bufnr)
  r17.lsp.mappings(bufnr, client)
  r17.lsp.autocmds(client, bufnr)
end

local function lsp_setup()
  require 'modules.lang.lsp.servers.bash'
  require 'modules.lang.lsp.servers.clangd'
  require 'modules.lang.lsp.servers.gopls'
  -- require 'modules.lang.lsp.servers.pyright'
  -- require 'modules.lang.lsp.servers.tsserver'
  require 'modules.lang.lsp.servers.sumneko_lua'
  require 'modules.lang.lsp.servers.simple_lsp'
  require 'modules.lang.lsp.servers.efm'
end

M.enhance_attach = enhance_attach
M.capabilities = capabilities
M.on_init = on_init
M.setup = lsp_setup

return M
