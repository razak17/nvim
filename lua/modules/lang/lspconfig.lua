local command = core.command

local get_cursor_pos = function()
  return {vim.fn.line('.'), vim.fn.col('.')}
end

local debounce = function(func, timeout)
  local timer_id = nil
  return function(...)
    if timer_id ~= nil then
      vim.fn.timer_stop(timer_id)
    end
    local args = {...}

    timer_id = vim.fn.timer_start(timeout, function()
      func(args)
      timer_id = nil
    end)
  end
end

local function lspLocList()
  core.augroup("LspLocationList", {
    {
      events = {"User LspDiagnosticsChanged"},
      command = function()
        vim.lsp.diagnostic.set_loclist {
          workspace = true,
          severity_limit = "Warning",
          open_loclist = false,
        }
      end,
    },
  })
end

local function documentFormatting(client)
  if client and client.resolved_capabilities.document_formatting then
    core.augroup("LspFormat", {
      {
        events = {"BufWritePre"},
        targets = {"<buffer>"},
        command = "lua vim.lsp.buf.formatting_sync(nil, 1000)",
      },
    })
  end
end

local function documentHighlight(client)
  if client and client.resolved_capabilities.document_highlight then
    core.augroup("LspCursorCommands", {
      {
        events = {"CursorHold"},
        targets = {"<buffer>"},
        command = "lua vim.lsp.buf.document_highlight()",
      },
      {
        events = {"CursorHoldI"},
        targets = {"<buffer>"},
        command = "lua vim.lsp.buf.document_highlight()",
      },
      {
        events = {"CursorMoved"},
        targets = {"<buffer>"},
        command = "lua vim.lsp.buf.clear_references()",
      },
    })
  end
end

local function hoverDiagnostics()
  core.augroup("HoverDiagnostics", {
    {
      events = {"CursorHold"},
      targets = {"<buffer>"},
      command = (function()
        local cursorpos = get_cursor_pos()
        return function()
          local new_cursor = get_cursor_pos()
          if (new_cursor[1] ~= 1 and new_cursor[2] ~= 1) and
            (new_cursor[1] ~= cursorpos[1] or new_cursor[2] ~= cursorpos[2]) then
            cursorpos = new_cursor
            if core.plugin.saga.active then
              vim.cmd [[packadd lspsaga.nvim]]
              debounce(require'lspsaga.diagnostic'.show_cursor_diagnostics(), 30)
            else
              vim.lsp.diagnostic.show_line_diagnostics({show_header = false, border = "single"})
            end
          end
        end
      end)(),
    },
  })
end

local function lsp_autocmds(client)
  lspLocList()
  if core.lsp.format_on_save then
    documentFormatting(client)
  end
  if core.lsp.document_highlight then
    documentHighlight(client)
  end
  if core.lsp.hover_diagnostics then
    hoverDiagnostics()
  end
end

local function lsp_mappings(client, bufnr)
  local nnoremap, vnoremap = core.nnoremap, core.vnoremap
  local lsp_popup = {{popup_opts = {border = "single", focusable = false}}}

  if not core.plugin.saga.active then
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
        require'lsp.utils'.PeekDefinition()
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
  nnoremap("<leader>vF", vim.lsp.buf.formatting)
  nnoremap("<leader>vf", ":Format<CR>")
  nnoremap("<leader>vl", vim.lsp.diagnostic.set_loclist)
end

function core.lsp.tagfunc(pattern, flags)
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
  "LspRestart",
  function()
    vim.lsp.stop_client(vim.lsp.get_active_clients())
    vim.cmd [[edit]]
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

function core.lsp.on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  lsp_autocmds(client)
  lsp_mappings(client, bufnr)

  if client.resolved_capabilities.goto_definition then
    vim.bo[bufnr].tagfunc = "v:lua.core.lsp.tagfunc"
  end

  -- on init
  client.config.flags = {}
  if client.config.flags then
    client.config.flags.allow_incremental_sync = true
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

core.lsp.capabilities = capabilities

function core.lsp.setup_servers()
  require'lsp.clang'.init()
  require'lsp.cmake'.init()
  require'lsp.dockerfile'.init()
  require'lsp.elixir'.init()
  require'lsp.go'.init()
  require'lsp.graphql'.init()
  require'lsp.html'.init()
  require'lsp.json'.init()
  require'lsp.lua'.init(capabilities)
  require'lsp.python'.init()
  require'lsp.rust'.init()
  require'lsp.sh'.init()
  require'lsp.vim'.init()
  require'lsp.yaml'.init()
  require'lsp.tsserver'.init()
  require'lsp.tsserver.lint'.init()
  -- require'lsp.efm'.setup(capabilities)

  vim.cmd "doautocmd User LspServersStarted"
end

local function lsp_setup()
  if vim.g.lspconfig_has_setup then
    return
  end
  vim.g.lspconfig_has_setup = true

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
    border = core.lsp.popup_border,
  })

  vim.lsp.handlers["textDocument/signatureHelp"] =
    vim.lsp.with(vim.lsp.handlers.signature_help, {border = core.lsp.popup_border})

  core.lsp.setup_servers()
end

lsp_setup()

