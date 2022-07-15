local M = {}

function M.init(client)
  if not client == nil then return end

  local function with_desc(desc) return { buffer = 0, desc = desc } end
  local nnoremap = rvim.nnoremap
  local xnoremap = rvim.xnoremap

  nnoremap('gl', function()
    local config = rvim.lsp.diagnostics.float
    config.scope = 'line'
    return vim.diagnostic.open_float({ scope = 'line' }, config)
  end, with_desc('lsp: line diagnostics'))

  if client.server_capabilities.codeActionProvider then
    nnoremap('<leader>la', vim.lsp.buf.code_action, with_desc('lsp: code action'))
    xnoremap(
      '<leader>la',
      '<esc><Cmd>lua vim.lsp.buf.range_code_action()<CR>',
      with_desc('lsp: code action')
    )
  end

  if client.server_capabilities.hoverProvider then
    nnoremap('K', vim.lsp.buf.hover, with_desc('lsp: hover'))
  end

  if client.server_capabilities.definitionProvider then
    nnoremap('gd', vim.lsp.buf.definition, with_desc('lsp: definition'))
  end

  if client.server_capabilities.referencesProvider then
    nnoremap('gr', vim.lsp.buf.references, with_desc('lsp: references'))
  end

  if client.server_capabilities.declarationProvider then
    nnoremap('gD', vim.lsp.buf.declaration, with_desc('lsp: go to declaration'))
  end

  if client.server_capabilities.implementationProvider then
    nnoremap('gi', vim.lsp.buf.implementation, with_desc('lsp: go to implementation'))
  end

  if client.server_capabilities.typeDefinitionProvider then
    nnoremap('gt', vim.lsp.buf.type_definition, with_desc('lsp: go to type definition'))
  end

  if client.supports_method('textDocument/prepareCallHierarchy') then
    nnoremap('gI', vim.lsp.buf.incoming_calls, with_desc('lsp: incoming calls'))
  end

  ------------------------------------------------------------------------------
  -- leader keymaps
  ------------------------------------------------------------------------------

  -- Peek
  nnoremap(
    '<leader>lp',
    "<cmd>lua require('user.lsp.peek').Peek('definition')<cr>",
    with_desc('peek: definition')
  )
  nnoremap(
    '<leader>li',
    "<cmd>lua require('user.lsp.peek').Peek('implementation')<cr>",
    with_desc('peek: implementation')
  )
  nnoremap(
    '<leader>lt',
    "<cmd>lua require('user.lsp.peek').Peek('typeDefinition')<cr>",
    with_desc('peek: type definition')
  )

  nnoremap('<leader>lk', function()
    if rvim.lsp.hover_diagnostics then
      vim.diagnostic.goto_prev({ float = false })
    else
      vim.diagnostic.goto_prev()
    end
  end, with_desc('lsp: go to prev diagnostic'))
  nnoremap('<leader>lj', function()
    if rvim.lsp.hover_diagnostics then
      vim.diagnostic.goto_next({ float = false })
    else
      vim.diagnostic.goto_next()
    end
  end, with_desc('lsp: go to next diagnostic'))
  nnoremap('<leader>lL', vim.diagnostic.setloclist, with_desc('lsp: toggle loclist diagnostics'))

  if client.server_capabilities.documentFormattingProvider then
    nnoremap('<leader>lf', '<cmd>LspFormat<cr>', with_desc('lsp: format buffer'))
  end

  if client.server_capabilities.codeLensProvider then
    nnoremap('<leader>lc', vim.lsp.codelens.run, with_desc('lsp: run code lens'))
  end

  if client.server_capabilities.renameProvider then
    nnoremap('<leader>lr', vim.lsp.buf.rename, with_desc('lsp: rename'))
  end
  -- Templates
  nnoremap('<leader>lG', function()
    require('user.lsp.templates').generate_templates()
    vim.notify('Templates have been generated', nil, { title = 'Lsp' })
  end, 'lsp: generate templates')
  nnoremap('<leader>lD', function()
    require('user.lsp.templates').remove_template_files()
    vim.notify('Templates have been removed', nil, { title = 'Lsp' })
  end, 'lsp: delete templates')
end

return M
