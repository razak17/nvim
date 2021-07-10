local M = {}

local on_init = function(client)
  client.config.flags = {}
  if client.config.flags then client.config.flags.allow_incremental_sync = true end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {'documentation', 'detail', 'additionalTextEdits'},
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

vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    update_in_insert = false,
    virtual_text = {spacing = 0, prefix = ''},
    signs = {enable = true, priority = 20},
  })

-- NOTE: the hover handler returns the bufnr,winnr so can be use for mappings
vim.lsp.handlers["textDocument/hover"] =
  vim.lsp.with(vim.lsp.handlers.hover, {border = "single"})

vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(vim.lsp.handlers.signature_help, {border = "single"})

local enhance_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  if client.resolved_capabilities.goto_definition then
    vim.bo[bufnr].tagfunc = "v:lua.as.lsp.tagfunc"
  end

  core.lsp.saga(bufnr)
  core.lsp.mappings(bufnr, client)
  core.lsp.autocmds(client, bufnr)
end

local function setup_servers()
  require 'modules.lang.lsp.servers.bash'
  require 'modules.lang.lsp.servers.clangd'
  require 'modules.lang.lsp.servers.gopls'
  require 'modules.lang.lsp.servers.pyright'
  require 'modules.lang.lsp.servers.tsserver'
  require 'modules.lang.lsp.servers.sumneko_lua'
  require 'modules.lang.lsp.servers.simple_lsp'
  require 'modules.lang.lsp.servers.efm'
end

M.enhance_attach = enhance_attach
M.capabilities = capabilities
M.on_init = on_init
M.setup = setup_servers

return M
