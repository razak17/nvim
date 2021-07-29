local M = {}

local nnoremap, vnoremap = rvim.nnoremap, rvim.vnoremap
local lsp_popup = { show_header = false, border = "single", focusable = false }
local buf_clients = vim.lsp.buf_get_clients()

function M.init()
  for _, client in pairs(buf_clients) do
    if client.resolved_capabilities.implementation then
      nnoremap("gi", vim.lsp.buf.implementation)
    end
    if client.resolved_capabilities.type_definition then
    nnoremap("<leader>ge", vim.lsp.buf.type_definition)
    end
  end
  nnoremap("gd", vim.lsp.buf.definition)
  nnoremap("gD", vim.lsp.buf.declaration)
  nnoremap("gr", vim.lsp.buf.references)
  nnoremap("K", vim.lsp.buf.hover)
  nnoremap("<Leader>vdb", function()
    vim.lsp.diagnostic.goto_prev { popup_opts = lsp_popup }
  end)
  nnoremap("<Leader>vdn", function()
    vim.lsp.diagnostic.goto_next { popup_opts = lsp_popup }
  end)
  nnoremap("<Leader>vdl", function()
    vim.lsp.diagnostic.show_line_diagnostics { popup_opts = lsp_popup }
  end)
  nnoremap("gh", function()
    require("lsp.peek").PeekDefinition()
  end)
  nnoremap("ge", function()
    require("lsp.peek").PeekImplementation()
  end)
  nnoremap("gL", function()
    require("lsp.peek").PeekTypeDefinition()
  end)
  nnoremap("gE", vim.lsp.buf.type_definition)
  nnoremap("grn", vim.lsp.buf.rename)
  nnoremap("gI", vim.lsp.buf.incoming_calls)
  nnoremap("<leader>va", vim.lsp.buf.code_action)
  vnoremap("<leader>vA", vim.lsp.buf.range_code_action)
  nnoremap("gsd", vim.lsp.buf.document_symbol)
  nnoremap("gsw", vim.lsp.buf.workspace_symbol)
  nnoremap("<leader>vf", ":LspFormat<CR>")
  nnoremap("<leader>vl", vim.lsp.diagnostic.set_loclist)
end

return M
