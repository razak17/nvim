local M = {}

local nnoremap, vnoremap = rvim.nnoremap, rvim.vnoremap

local function lsp_mappings(client)
  if client == nil then
    return
  end

  -- Definition
  if client.supports_method "textDocument/definition" then
    nnoremap("gd", vim.lsp.buf.definition)
    nnoremap("ge", function()
      require("user.lsp.peek").Peek "definition"
    end)
  end
  -- Declaration
  if client.supports_method "textDocument/declaration" then
    nnoremap("gD", vim.lsp.buf.declaration)
  end
  -- References
  if client.supports_method "textDocument/references" then
    nnoremap("gr", vim.lsp.buf.references)
  end
  -- Implementation
  if client.supports_method "textDocument/implementation" then
    nnoremap("gi", vim.lsp.buf.implementation)
    nnoremap("gl", function()
      require("user.lsp.peek").Peek "implementation"
    end)
  end
  -- Hover
  if client.supports_method "textDocument/hover" then
    nnoremap("K", vim.lsp.buf.hover)
  end
  -- Type Definition
  if client.supports_method "textDocument/type_definition" then
    nnoremap("gE", vim.lsp.buf.type_definition)
    nnoremap("gL", function()
      require("user.lsp.peek").Peek "typeDefinition"
    end)
  end
  -- Rename
  if client.supports_method "textDocument/rename" then
    nnoremap("grn", vim.lsp.buf.rename)
  end
  -- Call Hierarchy
  if client.supports_method "textDocument/prepareCallHierarchy" then
    nnoremap("gI", vim.lsp.buf.incoming_calls)
  end
  -- Symbols
  if client.supports_method "workspace/symbol" then
    nnoremap("gsd", vim.lsp.buf.document_symbol)
    nnoremap("gsw", vim.lsp.buf.workspace_symbol)
  end
end

local function lsp_leader_keymaps(client)
  if client == nil then
    return
  end

  -- Formatting
  if client.supports_method "textDocument/formatting" then
    nnoremap("<leader>vf", ":LspFormat<CR>")
  end
  -- Diagnostics
  if client.supports_method "textDocument/publishDiagnostics" then
    nnoremap("<Leader>vdb", function()
      vim.diagnostic.goto_prev { border = rvim.lsp.diagnostics.border }
    end)
    nnoremap("<Leader>vdn", function()
      vim.diagnostic.goto_next { border = rvim.lsp.diagnostics.border }
    end)
    nnoremap("<Leader>vdl", function()
      vim.lsp.diagnostic.show_line_diagnostics { border = rvim.lsp.diagnostics.border }
    end)
    nnoremap("<leader>vl", function()
      vim.diagnostic.setloclist()
    end)
  end
  -- Code Action
  if client.supports_method "textDocument/codeAction" then
    nnoremap("<leader>va", vim.lsp.buf.code_action)
    vnoremap("<leader>vA", vim.lsp.buf.range_code_action)
  end
end

function M:init(client)
  lsp_mappings(client)
  lsp_leader_keymaps(client)
end

return M
