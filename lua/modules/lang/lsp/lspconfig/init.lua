r17.lsp = {}

local command = r17.command

local get_cursor_pos = function() return {vim.fn.line('.'), vim.fn.col('.')} end

local debounce = function(func, timeout)
  local timer_id = nil
  return function(...)
    if timer_id ~= nil then vim.fn.timer_stop(timer_id) end
    local args = {...}

    timer_id = vim.fn.timer_start(timeout, function()
      func(args)
      timer_id = nil
    end)
  end
end

function r17.lsp.autocmds(client, _)
  r17.augroup("LspLocationList", {
    {
      events = {"InsertLeave", "BufWrite", "BufEnter"},
      targets = {"<buffer>"},
      command = [[lua vim.lsp.diagnostic.set_loclist({open_loclist = false})]],
    },
  })
  r17.augroup("HoverDiagnostics", {
    {
      events = {"CursorHold"},
      targets = {"<buffer>"},
      command = (function()
        vim.cmd [[packadd lspsaga.nvim]]
        local debounced = debounce(
                              require'lspsaga.diagnostic'.show_cursor_diagnostics,
                              30)
        local cursorpos = get_cursor_pos()
        return function()
          local new_cursor = get_cursor_pos()
          if (new_cursor[1] ~= 1 and new_cursor[2] ~= 1) and
              (new_cursor[1] ~= cursorpos[1] or new_cursor[2] ~= cursorpos[2]) then
            cursorpos = new_cursor
            debounced()
          end
        end
      end)()
    }
  })
  if client and client.resolved_capabilities.document_highlight then
    r17.augroup("LspCursorCommands", {
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
  r17.augroup("NvimLightbulb", {
    {
      events = {"CursorHold", "CursorHoldI"},
      targets = {"*"},
      command = function()
        require("nvim-lightbulb").update_lightbulb {
          sign = {enabled = false},
          virtual_text = {enabled = true},
        }
      end,
    },
  })
  if client and client.resolved_capabilities.document_formatting then
    -- format on save
    r17.augroup("Format", {
      {
        events = {"BufWritePre"},
        targets = {"*." .. vim.fn.expand('%:e')},
        command = "lua vim.lsp.buf.formatting_sync(nil, 1000)",
      },
    })
  end
end

function r17.lsp.saga(bufnr)
  vim.cmd [[packadd lspsaga.nvim]]
  local saga = require 'lspsaga'
  saga.init_lsp_saga {
    use_saga_diagnostic_sign = false,
    code_action_icon = '💡',
    code_action_prompt = {enable = false, sign = false, virtual_text = false},
  }
  local nnoremap, vnoremap, opts = r17.nnoremap, r17.vnoremap,
    {buffer = bufnr, check_existing = true}
  nnoremap("gd", ":Lspsaga lsp_finder<CR>", opts)
  nnoremap("gsh", ":Lspsaga signature_help<CR>", opts)
  nnoremap("gh", ":Lspsaga preview_definition<CR>", opts)
  nnoremap("grr", ":Lspsaga rename<CR>", opts)
  nnoremap("K", ":Lspsaga hover_doc<CR>", opts)
  nnoremap("<Leader>va", ":Lspsaga code_action<CR>", opts)
  vnoremap("<Leader>vA", ":Lspsaga range_code_action<CR>", opts)
  nnoremap("<Leader>vdb", ":Lspsaga diagnostic_jump_prev<CR>", opts)
  nnoremap("<Leader>vdn", ":Lspsaga diagnostic_jump_next<CR>", opts)
  nnoremap("<Leader>vdl", ":Lspsaga show_line_diagnostics<CR>", opts)
end

function r17.lsp.mappings(bufnr, client)
  local nnoremap, vnoremap, opts = r17.nnoremap, r17.vnoremap,
    {buffer = bufnr, check_existing = true}
  if client.resolved_capabilities.implementation then
    nnoremap("gi", vim.lsp.buf.implementation, opts)
  end

  if client.resolved_capabilities.type_definition then
    nnoremap("<leader>ge", vim.lsp.buf.type_definition, opts)
  end
  nnoremap("gsd", vim.lsp.buf.document_symbol, opts)
  nnoremap("gsw", vim.lsp.buf.workspace_symbol, opts)
  nnoremap("gI", vim.lsp.buf.incoming_calls, opts)
  nnoremap("gR", vim.lsp.buf.references, opts)
  nnoremap("gD", vim.lsp.buf.definition, opts)
  nnoremap("grn", vim.lsp.buf.rename, opts)
  vnoremap("<leader>va", vim.lsp.buf.code_action, opts)
  vnoremap("<leader>vA", vim.lsp.buf.range_code_action, opts)
  nnoremap("<leader>vf", vim.lsp.buf.formatting, opts)
  nnoremap("<leader>vl", vim.lsp.diagnostic.set_loclist, opts)
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
    vim.lsp.buf.formatting(vim.g[string.format("format_options_%s",
      vim.bo.filetype)] or {})
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

vim.fn.sign_define({
  {
    name = "LspDiagnosticsSignError",
    text = "",
    texthl = "LspDiagnosticsSignError",
  },
  {
    name = "LspDiagnosticsSignWarning",
    text = "",
    texthl = "LspDiagnosticsSignWarning",
  },
  {
    name = "LspDiagnosticsSignHint",
    text = "",
    texthl = "LspDiagnosticsSignHint",
  },
  {
    name = "LspDiagnosticsSignInformation",
    text = "",
    texthl = "LspDiagnosticsSignInformation",
  },
})

require'modules.lang.lsp.servers'.setup()
