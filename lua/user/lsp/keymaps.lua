local M = {}

function M.init(client)
  if not client == nil then
    return
  end

  local function with_desc(desc)
    return { buffer = 0, desc = desc }
  end

  rvim.nnoremap("gl", function()
    local config = rvim.lsp.diagnostics.float
    config.scope = "line"
    return vim.diagnostic.open_float({ scope = "line" }, config)
  end, with_desc("lsp: line diagnostics"))

  if client.server_capabilities.codeActionProvider then
    rvim.nnoremap("<leader>la", vim.lsp.buf.code_action, with_desc("lsp: code action"))
    rvim.xnoremap(
      "<leader>la",
      "<esc><Cmd>lua vim.lsp.buf.range_code_action()<CR>",
      with_desc("lsp: code action")
    )
  end

  if client.server_capabilities.hoverProvider then
    rvim.nnoremap("K", vim.lsp.buf.hover, with_desc("lsp: hover"))
  end

  if client.server_capabilities.definitionProvider then
    rvim.nnoremap("gd", vim.lsp.buf.definition, with_desc("lsp: definition"))
  end

  if client.server_capabilities.referencesProvider then
    rvim.nnoremap("gr", vim.lsp.buf.references, with_desc("lsp: references"))
  end

  if client.server_capabilities.declarationProvider then
    rvim.nnoremap("gD", vim.lsp.buf.declaration, with_desc("lsp: go to declaration"))
  end

  if client.server_capabilities.implementationProvider then
    rvim.nnoremap("gi", vim.lsp.buf.implementation, with_desc("lsp: go to implementation"))
  end

  if client.server_capabilities.typeDefinitionProvider then
    rvim.nnoremap("gt", vim.lsp.buf.type_definition, with_desc("lsp: go to type definition"))
  end

  if client.supports_method("textDocument/prepareCallHierarchy") then
    rvim.nnoremap("gI", vim.lsp.buf.incoming_calls, with_desc("lsp: incoming calls"))
  end

  ------------------------------------------------------------------------------
  -- leader keymaps
  ------------------------------------------------------------------------------

  -- Peek
  if client.server_capabilities.definitionProvider then
    rvim.nnoremap(
      "<leader>lpd",
      "<cmd>lua require('user.lsp.peek').Peek('definition')<cr>",
      with_desc("peek: definition")
    )
  end
  if client.server_capabilities.implementationProvider then
    rvim.nnoremap(
      "<leader>lpi",
      "<cmd>lua require('user.lsp.peek').peek('implementation')<cr>",
      with_desc("peek: implementation")
    )
  end
  if client.server_capabilities.typeDefinitionProvider then
    rvim.nnoremap(
      "<leader>lpt",
      "<cmd>lua require('user.lsp.peek').Peek('typeDefinition')<cr>",
      with_desc("peek: type definition")
    )
  end

  rvim.nnoremap("<leader>lk", vim.diagnostic.goto_prev, with_desc("lsp: go to prev diagnostic"))
  rvim.nnoremap("<leader>lj", vim.diagnostic.goto_next, with_desc("lsp: go to next diagnostic"))
  rvim.nnoremap("<leader>lL", vim.diagnostic.setloclist, with_desc("lsp: set loclist"))

  if client.server_capabilities.documentFormattingProvider then
    rvim.nnoremap("<leader>lf", "<cmd>LspFormat<cr>", with_desc("lsp: format buffer"))
  end

  if client.server_capabilities.codeLensProvider then
    rvim.nnoremap("<leader>lc", vim.lsp.codelens.run, with_desc("lsp: run code lens"))
  end

  if client.server_capabilities.renameProvider then
    rvim.nnoremap("<leader>lr", vim.lsp.buf.rename, with_desc("lsp: rename"))
  end
end

return M
