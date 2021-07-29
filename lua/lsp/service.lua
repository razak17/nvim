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

function M.on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  lsp_highlight_document(client)
end

function M.no_formatter_on_attach(client, bufnr)
  if rvim.lsp.on_attach_callback then
    rvim.lsp.on_attach_callback(client, bufnr)
  end
  lsp_highlight_document(client)
  client.resolved_capabilities.document_formatting = false
end

return M
