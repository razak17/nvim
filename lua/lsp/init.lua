local lsp_config = {}

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
    underline = core.lsp.diagnostics.underline,
    update_in_insert = core.lsp.diagnostics.update_in_insert,
    virtual_text = core.lsp.diagnostics.virtual_text,
    signs = core.lsp.diagnostics.signs,
  })

vim.lsp.handlers["textDocument/hover"] =
  vim.lsp.with(vim.lsp.handlers.hover,
    {show_header = false, border = core.lsp.popup_border})

vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(vim.lsp.handlers.signature_help, {border = core.lsp.popup_border})

local enhance_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  if client.resolved_capabilities.goto_definition then
    vim.bo[bufnr].tagfunc = "v:lua.as.lsp.tagfunc"
  end

  core.lsp.autocmds(client)

  if core.plugin.saga.active then
    core.lsp.saga(bufnr)
  else
    core.lsp.mappings(bufnr, client)
  end
end

-- Taken from https://www.reddit.com/r/neovim/comments/gyb077/nvimlsp_peek_defination_javascript_ttserver/
function lsp_config.preview_location(location, context, before_context)
  -- location may be LocationLink or Location (more useful for the former)
  context = context or 15
  before_context = before_context or 0
  local uri = location.targetUri or location.uri
  if uri == nil then return end
  local bufnr = vim.uri_to_bufnr(uri)
  if not vim.api.nvim_buf_is_loaded(bufnr) then vim.fn.bufload(bufnr) end

  local range = location.targetRange or location.range
  local contents = vim.api.nvim_buf_get_lines(bufnr, range.start.line -
    before_context, range["end"].line + 1 + context, false)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  return vim.lsp.util.open_floating_preview(contents, filetype,
    {border = core.lsp.popup_border})
end

function lsp_config.preview_location_callback(_, method, result)
  local context = 15
  if result == nil or vim.tbl_isempty(result) then
    print("No location found: " .. method)
    return nil
  end
  if vim.tbl_islist(result) then
    lsp_config.floating_buf, lsp_config.floating_win =
      lsp_config.preview_location(result[1], context)
  else
    lsp_config.floating_buf, lsp_config.floating_win =
      lsp_config.preview_location(result, context)
  end
end

function lsp_config.PeekDefinition()
  if vim.tbl_contains(vim.api.nvim_list_wins(), lsp_config.floating_win) then
    vim.api.nvim_set_current_win(lsp_config.floating_win)
  else
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(0, "textDocument/definition", params,
      lsp_config.preview_location_callback)
  end
end

function lsp_config.PeekTypeDefinition()
  if vim.tbl_contains(vim.api.nvim_list_wins(), lsp_config.floating_win) then
    vim.api.nvim_set_current_win(lsp_config.floating_win)
  else
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(0, "textDocument/typeDefinition", params,
      lsp_config.preview_location_callback)
  end
end

function lsp_config.PeekImplementation()
  if vim.tbl_contains(vim.api.nvim_list_wins(), lsp_config.floating_win) then
    vim.api.nvim_set_current_win(lsp_config.floating_win)
  else
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(0, "textDocument/implementation", params,
      lsp_config.preview_location_callback)
  end
end

local function setup_servers()
  require 'lsp.bash'
  require 'lsp.clang'
  require 'lsp.go'
  require 'lsp.lua'
  require 'lsp.python'
  require 'lsp.simple'
  require 'lsp.tsserver'
  require 'lsp.efm'
end

lsp_config.on_init = on_init
lsp_config.capabilities = capabilities
lsp_config.enhance_attach = enhance_attach
lsp_config.setup = setup_servers

return lsp_config
