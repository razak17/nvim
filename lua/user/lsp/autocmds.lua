local M = {}

function M.enable_lsp_document_highlight(client_id)
  rvim.augroup("LspCursorCommands", {
    {
      event = { "CursorHold" },
      buffer = 0,
      command = string.format(
        "lua require('user.lsp.utils').conditional_document_highlight(%d)",
        client_id
      ),
    },
    {
      event = { "CursorHoldI" },
      buffer = 0,
      command = "lua vim.lsp.buf.document_highlight()",
    },
    {
      event = { "CursorMoved" },
      buffer = 0,
      command = function()
        vim.lsp.buf.clear_references()
      end,
    },
  })
end

function M.disable_lsp_document_highlight()
  rvim.disable_augroup "lsp_document_highlight"
end

function M.enable_code_lens_refresh()
  rvim.augroup("LspCodeLensRefresh", {
    {
      event = { "InsertLeave" },
      buffer = 0,
      command = "lua vim.lsp.codelens.refresh()",
    },
    {
      event = { "InsertLeave" },
      buffer = 0,
      command = "lua vim.lsp.codelens.display()",
    },
  })
end

function M.disable_code_lens_refresh()
  rvim.disable_augroup "lsp_code_lens_refresh"
end

function M.enable_lsp_hover_diagnostics()
  local get_cursor_pos = function()
    return { vim.fn.line ".", vim.fn.col "." }
  end

  rvim.augroup("HoverDiagnostics", {
    {
      event = { "CursorHold" },
      buffer = 0,
      command = (function()
        local cursorpos = get_cursor_pos()
        return function()
          local new_cursor = get_cursor_pos()
          if
            (new_cursor[1] ~= 1 and new_cursor[2] ~= 1)
            and (new_cursor[1] ~= cursorpos[1] or new_cursor[2] ~= cursorpos[2])
          then
            cursorpos = new_cursor
            vim.lsp.diagnostic.show_line_diagnostics { show_header = false, border = "single" }
          end
        end
      end)(),
    },
  })
end

return M
