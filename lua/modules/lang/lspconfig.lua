local command = rvim.command
local lsp_utils = require('lsp.utils')

local function lsp_autocmds()
  lsp_utils.LocList()
  if rvim.lsp.hover_diagnostics then
    lsp_utils.hover_diagnostics()
  end
end

local lsp_config = {}

-- Taken from https://www.reddit.com/r/neovim/comments/gyb077/nvimlsp_peek_defination_javascript_ttserver/
function lsp_config.preview_location(location, context, before_context)
  -- location may be LocationLink or Location (more useful for the former)
  context = context or 15
  before_context = before_context or 0
  local uri = location.targetUri or location.uri
  if uri == nil then
    return
  end
  local bufnr = vim.uri_to_bufnr(uri)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end

  local range = location.targetRange or location.range
  local contents = vim.api.nvim_buf_get_lines(bufnr, range.start.line - before_context,
    range["end"].line + 1 + context, false)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  return vim.lsp.util.open_floating_preview(contents, filetype, {border = rvim.lsp.popup_border})
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
    lsp_config.floating_buf, lsp_config.floating_win = lsp_config.preview_location(result, context)
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

local function lsp_mappings(client, bufnr)
  local nnoremap, vnoremap = rvim.nnoremap, rvim.vnoremap
  local lsp_popup = {{popup_opts = {border = "single", focusable = false}}}

  if not rvim.plugin.saga.active then
    nnoremap("gd", vim.lsp.buf.definition)
    nnoremap("gD", vim.lsp.buf.declaration)
    nnoremap("gr", vim.lsp.buf.references)
    nnoremap("K", vim.lsp.buf.hover)
    nnoremap("<Leader>vdb", function()
      vim.lsp.diagnostic.goto_prev({lsp_popup})
    end)
    nnoremap("<Leader>vdn", function()
      vim.lsp.diagnostic.goto_next({lsp_popup})
    end)
    nnoremap("<Leader>vdl", function()
      vim.lsp.diagnostic.show_line_diagnostics({lsp_popup})
    end)

    if client.resolved_capabilities.implementation then
      nnoremap("gi", vim.lsp.buf.implementation)
    end
    if client.supports_method "textDocument/definition" then
      nnoremap("ge", function()
        lsp_config.PeekDefinition()
      end)
    end
    if client.resolved_capabilities.type_definition then
      nnoremap("<leader>ge", vim.lsp.buf.type_definition)
    end
    if client.supports_method "textDocument/rename" then
      nnoremap("grn", vim.lsp.buf.rename)
    end
    if client.supports_method "textDocument/prepareCallHierarchy" then
      nnoremap("gI", vim.lsp.buf.incoming_calls)
    end
    if client.supports_method "textDocument/codeAction" then
      nnoremap("<leader>va", vim.lsp.buf.code_action)
      vnoremap("<leader>vA", vim.lsp.buf.range_code_action)
    end
  end

  nnoremap("gsd", vim.lsp.buf.document_symbol)
  nnoremap("gsw", vim.lsp.buf.workspace_symbol)
  nnoremap("<leader>vf", ":Format<CR>")
  nnoremap("<leader>vl", vim.lsp.diagnostic.set_loclist)
end

function rvim.lsp.tagfunc(pattern, flags)
  if flags ~= "c" then
    return vim.NIL
  end
  local params = vim.lsp.util.make_position_params()
  local client_id_to_results, err = vim.lsp.buf_request_sync(0, "textDocument/definition", params,
    500)
  assert(not err, vim.inspect(err))

  local results = {}
  for _, lsp_results in ipairs(client_id_to_results) do
    for _, location in ipairs(lsp_results.result or {}) do
      local start = location.range.start
      table.insert(results, {
        name = pattern,
        filename = vim.uri_to_fname(location.uri),
        cmd = string.format("call cursor(%d, %d)", start.line + 1, start.character + 1),
      })
    end
  end
  return results
end

-- symbols for autocomplete
vim.lsp.protocol.CompletionItemKind = {
  "   (Text) ",
  "   (Method)",
  " ƒ  (Function)",
  "   (Constructor)",
  " ﴲ  (Field)",
  "   (Variable)",
  "   (Class)",
  " ﰮ  (Interface)",
  "   (Module)",
  " 襁 (Property)",
  "   (Unit)",
  "   (Value)",
  " 了 (Enum)",
  "   (Keyword)",
  "   (Snippet)",
  "   (Color)",
  "   (File)",
  "   (Reference)",
  "   (Folder)",
  "   (EnumMember)",
  "   (Constant)",
  " ﳤ  (Struct)",
  " 鬒 (Event)",
  "   (Operator)",
  "   (TypeParameter)",
}

command {
  "LspLog",
  function()
    local path = vim.lsp.get_log_path()
    vim.cmd("edit " .. path)
  end,
}

command {
  "LspFormat",
  function()
    vim.lsp.buf.formatting(vim.g[string.format("format_options_%s", vim.bo.filetype)] or {})
  end,
}

command {
  "LspToggleVirtualText",
  function()
    local virtual_text = {}
    virtual_text.show = true
    virtual_text.show = not virtual_text.show
    vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(0, 1), 0, 1,
      {virtual_text = virtual_text.show})
  end,
}

function rvim.lsp.on_attach(client, bufnr)
  lsp_autocmds()
  lsp_mappings(client, bufnr)

  if client.resolved_capabilities.goto_definition then
    vim.bo[bufnr].tagfunc = "v:lua.rvim.lsp.tagfunc"
  end
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

rvim.lsp.capabilities = capabilities

function rvim.lsp.setup_servers()
  require'lsp.clang'.init()
  require'lsp.cmake'.init()
  require'lsp.css'.init()
  require'lsp.dockerfile'.init()
  require'lsp.elixir'.init()
  require'lsp.go'.init()
  require'lsp.graphql'.init()
  require'lsp.html'.init()
  require'lsp.json'.init()
  require'lsp.lua'.init()
  require'lsp.python'.init()
  require'lsp.rust'.init()
  require'lsp.sh'.init()
  require'lsp.vim'.init()
  require'lsp.yaml'.init()
  require'lsp.tsserver'.init()
  require'lsp.tsserver.lint'.init()
  -- require'lsp.efm'.init()

  vim.cmd "doautocmd User LspServersStarted"
end

local function lsp_setup()
  vim.fn.sign_define {
    {name = "LspDiagnosticsSignError", text = "", texthl = "LspDiagnosticsSignError"},
    {name = "LspDiagnosticsSignHint", text = "", texthl = "LspDiagnosticsSignHint"},
    {name = "LspDiagnosticsSignWarning", text = "", texthl = "LspDiagnosticsSignWarning"},
    {name = "LspDiagnosticsSignInformation", text = "", texthl = "LspDiagnosticsSignInformation"},
  }

  vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      underline = true,
      update_in_insert = false,
      virtual_text = {spacing = 0, prefix = ""},
      signs = true,
    })

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    show_header = false,
    border = rvim.lsp.popup_border,
  })

  vim.lsp.handlers["textDocument/signatureHelp"] =
    vim.lsp.with(vim.lsp.handlers.signature_help, {border = rvim.lsp.popup_border})

  rvim.lsp.setup_servers()
end

lsp_setup()
