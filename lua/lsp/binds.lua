local M = {}

local nnoremap, vnoremap = rvim.nnoremap, rvim.vnoremap

local function lsp_mappings(client)
  -- Definition
  if client and client.supports_method "textDocument/definition" then
    nnoremap("gd", vim.lsp.buf.definition)
    nnoremap("ge", function()
      require("lsp.peek").Peek "definition"
    end)
  end
  -- Declaration
  if client and client.supports_method "textDocument/declaration" then
    nnoremap("gD", vim.lsp.buf.declaration)
  end
  -- References
  if client and client.supports_method "textDocument/references" then
    nnoremap("gr", vim.lsp.buf.references)
  end
  -- Implementation
  if client and client.supports_method "textDocument/implementation" then
    nnoremap("gi", vim.lsp.buf.implementation)
    nnoremap("gl", function()
      require("lsp.peek").Peek "implementation"
    end)
  end
  -- Hover
  if client and client.supports_method "textDocument/hover" then
    nnoremap("K", vim.lsp.buf.hover)
  end
  -- Type Definition
  if client and client.supports_method "textDocument/type_definition" then
    nnoremap("gE", vim.lsp.buf.type_definition)
    nnoremap("gL", function()
      require("lsp.peek").Peek "typeDefinition"
    end)
  end
  -- Rename
  if client and client.supports_method "textDocument/rename" then
    nnoremap("grn", vim.lsp.buf.rename)
  end
  -- Call Hierarchy
  if client and client.supports_method "textDocument/prepareCallHierarchy" then
    nnoremap("gI", vim.lsp.buf.incoming_calls)
  end
  -- Symbols
  if client and client.supports_method "workspace/symbol" then
    nnoremap("gsd", vim.lsp.buf.document_symbol)
    nnoremap("gsw", vim.lsp.buf.workspace_symbol)
  end
end

local function lsp_leader_keymaps(client)
  local lsp_popup = { show_header = false, border = "single", focusable = false }

  -- Formatting
  if client and client.supports_method "textDocument/formatting" then
    nnoremap("<leader>vf", ":LspFormat<CR>")
  end
  -- Diagnostics
  if client and client.supports_method "textDocument/publishDiagnostics" then
    nnoremap("<Leader>vdb", function()
      vim.lsp.diagnostic.goto_prev { popup_opts = lsp_popup }
    end)
    nnoremap("<Leader>vdn", function()
      vim.lsp.diagnostic.goto_next { popup_opts = lsp_popup }
    end)
    nnoremap("<Leader>vdl", function()
      vim.lsp.diagnostic.show_line_diagnostics { popup_opts = lsp_popup }
    end)
    nnoremap("<leader>vl", vim.lsp.diagnostic.set_loclist)
  end
  -- Code Action
  if client and client.supports_method "textDocument/codeAction" then
    nnoremap("<leader>va", vim.lsp.buf.code_action)
    vnoremap("<leader>vA", vim.lsp.buf.range_code_action)
  end
end

function M:init(client)
  lsp_mappings(client)
  lsp_leader_keymaps(client)
end

return M
