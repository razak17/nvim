local M = {}

local command = rvim.command
local nnoremap, vnoremap = rvim.nnoremap, rvim.vnoremap
local lsp_popup = { show_header = false, border = "single", focusable = false }

local function lsp_commands()
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
      vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(0, 1), 0, 1, { virtual_text = virtual_text.show })
    end,
  }
  command {
    "LspReload",
    function()
      vim.cmd [[
      :lua vim.lsp.stop_client(vim.lsp.get_active_clients())
      :edit
    ]]
    end,
  }
end

local function lsp_mappings()
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
    require("lsp.peek").Peek "definition"
  end)
  nnoremap("gl", function()
    require("lsp.peek").Peek "implementation"
  end)
  nnoremap("gL", function()
    require("lsp.peek").Peek "typeDefinition"
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

function M.init()
  lsp_commands()
  lsp_mappings()
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
