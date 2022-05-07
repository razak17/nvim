local M = {}

function M.init(client)
  if not client == nil then
    return
  end

  -- TODO: all references to `resolved_capabilities.capability_name` will need to be changed to
  -- `server_capabilities.camelCaseCapabilityName`
  -- use client.supports_method for now
  -- https://github.com/neovim/neovim/issues/14090#issuecomment-1113956767

  -- rvim.nnoremap("<leader>ca", vim.lsp.buf.code_action, "lsp: code action")
  -- rvim.xnoremap(
  --   "<leader>ca",
  --   "<esc><Cmd>lua vim.lsp.buf.range_code_action()<CR>",
  --   "lsp: code action"
  -- )

  rvim.nnoremap("gl", function()
    local config = rvim.lsp.diagnostics.float
    config.scope = "line"
    return vim.diagnostic.open_float({ scope = "line" }, config)
  end, "lsp: line diagnostics")

  if client.supports_method("textDocument/hover") then
    rvim.nnoremap("K", vim.lsp.buf.hover, "lsp: hover")
  end

  if client.supports_method("textDocument/definition") then
    rvim.nnoremap("gd", vim.lsp.buf.definition, "lsp: definition")
  end

  if client.supports_method("textDocument/references") then
    rvim.nnoremap("gr", vim.lsp.buf.references, "lsp: references")
  end

  if client.supports_method("textDocument/declaration") then
    rvim.nnoremap("<leader>ge", vim.lsp.buf.declaration, "lsp: go to declaration")
  end

  if client.supports_method("textDocument/implementation") then
    rvim.nnoremap("<leader>gi", vim.lsp.buf.implementation, "lsp: go to implementation")
  end

  if client.supports_method("textDocument/typeDefinition") then
    rvim.nnoremap("<leader>gT", vim.lsp.buf.type_definition, "lsp: go to type definition")
  end

  if client.supports_method("callHierarchy/incomingCalls") then
    rvim.nnoremap("gI", vim.lsp.buf.incoming_calls, "lsp: incoming calls")
  end

  ------------------------------------------------------------------------------
  -- leader keymaps
  ------------------------------------------------------------------------------

  rvim.nnoremap("<leader>lk", vim.diagnostic.goto_prev, "lsp: go to prev diagnostic")
  rvim.nnoremap("<leader>lj", vim.diagnostic.goto_next, "lsp: go to next diagnostic")
  rvim.nnoremap("<leader>lL", vim.diagnostic.setloclist, "lsp: set loclist")

  rvim.nnoremap(
    "<leader>lpd",
    "<cmd>lua require('user.lsp.peek').Peek('definition')<cr>",
    "peek: definition"
  )
  rvim.nnoremap(
    "<leader>lpi",
    "<cmd>lua require('user.lsp.peek').peek('implementation')<cr>",
    "peek: implementation"
  )
  rvim.nnoremap(
    "<leader>lpt",
    "<cmd>lua require('user.lsp.peek').Peek('typeDefinition')<cr>",
    "peek: type definition"
  )

  if client.supports_method("textDocument/formatting") then
    rvim.nnoremap("<leader>lf", "<cmd>LspFormat<cr>", "lsp: format buffer")
  end

  if client.supports_method("textDocument/codeLens") then
    rvim.nnoremap("<leader>lc", vim.lsp.codelens.run, "lsp: run code lens")
  end

  if client.supports_method("textDocument/rename") then
    rvim.nnoremap("<leader>lr", vim.lsp.buf.rename, "lsp: rename")
  end
end

return M
