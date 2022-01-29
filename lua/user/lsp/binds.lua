local M = {}

local nnoremap, vnoremap = rvim.nnoremap, rvim.vnoremap

local function lsp_mappings(client)
  if client == nil then
    return
  end

  -- Definition
  if client.supports_method "textDocument/definition" then
    nnoremap("gd", vim.lsp.buf.definition)
  end
  -- Declaration
  if client.supports_method "textDocument/declaration" then
    nnoremap("ge", vim.lsp.buf.declaration)
  end
  -- References
  if client.supports_method "textDocument/references" then
    nnoremap("gr", vim.lsp.buf.references)
  end
  -- Implementation
  if client.supports_method "textDocument/implementation" then
    nnoremap("gi", vim.lsp.buf.implementation)
  end
  -- Hover
  if client.supports_method "textDocument/hover" then
    nnoremap("K", vim.lsp.buf.hover)
  end
  -- Type Definition
  if client.supports_method "textDocument/type_definition" then
    nnoremap("gt", vim.lsp.buf.type_definition)
  end

  -- Rename
  if client.supports_method "textDocument/rename" then
    nnoremap("gn", vim.lsp.buf.rename)
  end
  -- Call Hierarchy
  if client.supports_method "textDocument/prepareCallHierarchy" then
    nnoremap("gI", vim.lsp.buf.incoming_calls)
  end
end

local function lsp_leader_keymaps(client)
  if client == nil then
    return
  end

  -- Peek
  nnoremap("<Leader>lpd", function()
    require("user.lsp.peek").Peek "definition"
  end)

  nnoremap("<Leader>lpi", function()
    require("user.lsp.peek").Peek "implementation"
  end)

  nnoremap("<Leader>lpt", function()
    require("user.lsp.peek").Peek "typeDefinition"
  end)

  -- Formatting
  if client.supports_method "textDocument/formatting" then
    nnoremap("<leader>lf", ":LspFormat<CR>")
  end
  -- Diagnostics
  if client.supports_method "textDocument/publishDiagnostics" then
    nnoremap("<Leader>lk", function()
      vim.diagnostic.goto_prev()
    end)
    nnoremap("<Leader>lj", function()
      vim.diagnostic.goto_next()
    end)
    nnoremap("<leader>ll", function()
      vim.diagnostic.setloclist()
    end)
  end
  -- Code Action
  if client.supports_method "textDocument/codeAction" then
    nnoremap("<leader>la", vim.lsp.buf.code_action)
    vnoremap("<leader>lA", vim.lsp.buf.range_code_action)
  end
end

function M:init(client)
  lsp_mappings(client)
  lsp_leader_keymaps(client)
end

return M
