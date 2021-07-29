local M = {}

local nnoremap, vnoremap = rvim.nnoremap, rvim.vnoremap
local lsp_popup = { show_header = false, border = "single", focusable = false }

function M.init()
  nnoremap("gd", vim.lsp.buf.definition)
  nnoremap("gD", vim.lsp.buf.declaration)
  nnoremap("gr", vim.lsp.buf.references)
  nnoremap("gi", vim.lsp.buf.implementation)
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
  nnoremap("ge", function()
    require("lsp.peek").PeekDefinition()
  end)
  nnoremap("gl", function()
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

-- function M.init(client)
--   -- Definition
--   if client and client.supports_method "textDocument/definition" then
--     nnoremap("gd", vim.lsp.buf.definition)
--   end
--   -- Declaration
--   if client and client.supports_method "textDocument/declaration" then
--     nnoremap("gD", vim.lsp.buf.declaration)
--   end
--   -- References
--   if client and client.supports_method "textDocument/references" then
--     nnoremap("gr", vim.lsp.buf.references)
--   end
--   -- Hover
--   if client and client.supports_method "textDocument/hover" then
--     nnoremap("K", vim.lsp.buf.hover)
--   end
--   -- Formatting
--   if client and client.supports_method "textDocument/formatting" then
--     nnoremap("<leader>vf", ":LspFormat<CR>")
--   end
--   -- Rename
--   if client and client.supports_method "textDocument/rename" then
--     nnoremap("grn", vim.lsp.buf.rename)
--   end
--   -- Call Hierarchy
--   if client and client.supports_method "textDocument/prepareCallHierarchy" then
--     nnoremap("gI", vim.lsp.buf.incoming_calls)
--   end
--   -- Code Action
--   if client and client.supports_method "textDocument/codeAction" then
--     nnoremap("<leader>va", vim.lsp.buf.code_action)
--     vnoremap("<leader>vA", vim.lsp.buf.range_code_action)
--   end
--   -- Implementation
--   if client and client.supports_method "textDocument/definition" then
--     nnoremap("gh", function()
--       require("lsp.peek").PeekDefinition()
--     end)
--   end
--   -- Implementation
--   if client and client.supports_method "textDocument/implementation" then
--     nnoremap("gi", vim.lsp.buf.implementation)
--     nnoremap("ge", function()
--       require("lsp.peek").PeekImplementation()
--     end)
--   end
--   -- Type Definition
--   if client and client.supports_method "textDocument/type_definition" then
--     nnoremap("gE", vim.lsp.buf.type_definition)
--     nnoremap("gL", function()
--       require("lsp.peek").PeekTypeDefinition()
--     end)
--   end
--   -- Diagnostics
--   if client and client.supports_method "textDocument/publishDiagnostics" then
--     nnoremap("<leader>vl", vim.lsp.diagnostic.set_loclist)
--     nnoremap("<Leader>vdb", function()
--       vim.lsp.diagnostic.goto_prev { popup_opts = lsp_popup }
--     end)
--     nnoremap("<Leader>vdn", function()
--       vim.lsp.diagnostic.goto_next { popup_opts = lsp_popup }
--     end)
--     nnoremap("<Leader>vdl", function()
--       vim.lsp.diagnostic.show_line_diagnostics { popup_opts = lsp_popup }
--     end)
--   end
--   -- Symbols
--   if client and client.supports_method "workspace/symbol" then
--     nnoremap("gsd", vim.lsp.buf.document_symbol)
--     nnoremap("gsw", vim.lsp.buf.workspace_symbol)
--   end
-- end

return M
