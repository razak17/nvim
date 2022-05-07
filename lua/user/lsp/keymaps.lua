local M = {}

function M.init(client)
  if not client == nil then
    return
  end

  local function with_desc(desc)
    return { buffer = 0, desc = desc }
  end

  -- TODO: all references to `resolved_capabilities.capability_name` will need to be changed to
  -- `server_capabilities.camelCaseCapabilityName`
  -- use client.supports_method for now
  -- https://github.com/neovim/neovim/issues/14090#issuecomment-1113956767

  -- rvim.nnoremap("<leader>ca", vim.lsp.buf.code_action, with_desc("lsp: code action"))
  -- rvim.xnoremap(
  --   "<leader>ca",
  --   "<esc><Cmd>lua vim.lsp.buf.range_code_action()<CR>",
  --   with_des("lsp: code action"))
  -- )

  rvim.nnoremap("gl", function()
    local config = rvim.lsp.diagnostics.float
    config.scope = "line"
    return vim.diagnostic.open_float({ scope = "line" }, config)
  end, with_desc("lsp: line diagnostics"))

  if client.supports_method("textDocument/hover") then
    rvim.nnoremap("K", vim.lsp.buf.hover, with_desc("lsp: hover"))
  end

  if client.supports_method("textDocument/definition") then
    rvim.nnoremap("gd", vim.lsp.buf.definition, with_desc("lsp: definition"))
  end

  if client.supports_method("textDocument/references") then
    rvim.nnoremap("gr", vim.lsp.buf.references, with_desc("lsp: references"))
  end

  if client.supports_method("textDocument/declaration") then
    rvim.nnoremap("<leader>ge", vim.lsp.buf.declaration, with_desc("lsp: go to declaration"))
  end

  if client.supports_method("textDocument/implementation") then
    rvim.nnoremap("<leader>gi", vim.lsp.buf.implementation, with_desc("lsp: go to implementation"))
  end

  if client.supports_method("textDocument/typeDefinition") then
    rvim.nnoremap(
      "<leader>gT",
      vim.lsp.buf.type_definition,
      with_desc("lsp: go to type definition")
    )
  end

  -- if client.supports_method("callHierarchy/incomingCalls") then
  if client.supports_method("textDocument/prepareCallHierarchy") then
    rvim.nnoremap("gI", vim.lsp.buf.incoming_calls, with_desc("lsp: incoming calls"))
  end

  ------------------------------------------------------------------------------
  -- leader keymaps
  ------------------------------------------------------------------------------

  rvim.nnoremap("<leader>lk", vim.diagnostic.goto_prev, with_desc("lsp: go to prev diagnostic"))
  rvim.nnoremap("<leader>lj", vim.diagnostic.goto_next, with_desc("lsp: go to next diagnostic"))
  rvim.nnoremap("<leader>lL", vim.diagnostic.setloclist, with_desc("lsp: set loclist"))

  rvim.nnoremap(
    "<leader>lpd",
    "<cmd>lua require('user.lsp.peek').Peek('definition')<cr>",
    with_desc("peek: definition")
  )
  rvim.nnoremap(
    "<leader>lpi",
    "<cmd>lua require('user.lsp.peek').peek('implementation')<cr>",
    with_desc("peek: implementation")
  )
  rvim.nnoremap(
    "<leader>lpt",
    "<cmd>lua require('user.lsp.peek').Peek('typeDefinition')<cr>",
    with_desc("peek: type definition")
  )

  if client.supports_method("textDocument/formatting") then
    rvim.nnoremap("<leader>lf", "<cmd>LspFormat<cr>", with_desc("lsp: format buffer"))
  end

  if client.supports_method("textDocument/codeLens") then
    rvim.nnoremap("<leader>lc", vim.lsp.codelens.run, with_desc("lsp: run code lens"))
  end

  if client.supports_method("textDocument/rename") then
    rvim.nnoremap("<leader>lr", vim.lsp.buf.rename, with_desc("lsp: rename"))
  end
end

return M
