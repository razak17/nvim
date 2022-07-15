-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/plugin/lsp.lua

local lsp = vim.lsp
local fn = vim.fn
local api = vim.api
local fmt = string.format
local AUGROUP = 'LspCommands'
local L = vim.lsp.log_levels

local icons = rvim.style.icons
local border = rvim.style.border.current
local diagnostic = vim.diagnostic

if vim.env.DEVELOPING then vim.lsp.set_log_level(L.DEBUG) end

-----------------------------------------------------------------------------//
-- Autocommands
-----------------------------------------------------------------------------//

-- Show the popup diagnostics window, but only once for the current cursor location
-- by checking whether the word under the cursor has changed.
local function diagnostic_popup()
  local cword = vim.fn.expand('<cword>')
  if cword ~= vim.w.lsp_diagnostics_cword then
    vim.w.lsp_diagnostics_cword = cword
    vim.diagnostic.open_float(0, { scope = 'cursor', focus = false })
  end
end

--- Add lsp autocommands
---@param client table<string, any>
---@param bufnr number
local function setup_autocommands(client, bufnr)
  local cmds = {}
  if not client then
    local msg = fmt('Unable to setup LSP autocommands, client for %d is missing', bufnr)
    return vim.notify(msg, 'error', { title = 'LSP Setup' })
  end
  if client.server_capabilities.documentFormattingProvider then
    -- Format On Save
    local opts = rvim.util.format_on_save
    if rvim.find_string(rvim.lsp.format_on_save_exclusions, vim.bo.ft) then return end
    table.insert(cmds, {
      event = { 'BufWritePre' },
      pattern = { opts.pattern },
      desc = 'Format the current buffer on save',
      command = function()
        require('user.utils.lsp').format({ timeout_ms = opts.timeout, filter = opts.filter })
      end,
    })
  end
  if client.server_capabilities.codeLensProvider then
    if rvim.lsp.code_lens_refresh then
      -- Code Lens
      table.insert(cmds, {
        event = { 'BufEnter', 'CursorHold', 'InsertLeave' },
        buffer = bufnr,
        command = function(args)
          if api.nvim_buf_is_valid(args.buf) then vim.lsp.codelens.refresh() end
        end,
      })
    end
  end
  if client.server_capabilities.documentHighlightProvider then
    if rvim.lsp.hover_diagnostics then
      -- Hover Diagnostics
      table.insert(cmds, {
        event = { 'CursorHold' },
        buffer = bufnr,
        desc = 'Show diagnostics on hover',
        command = function() diagnostic_popup() end,
      })
    end
    if rvim.lsp.document_highlight then
      -- Cursor Commands
      table.insert(cmds, {
        event = { 'CursorHold', 'CursorHoldI' },
        buffer = bufnr,
        desc = 'LSP: Document Highlight',
        command = function() vim.lsp.buf.document_highlight() end,
      })
      table.insert(cmds, {
        event = { 'CursorMoved' },
        desc = 'LSP: Document Highlight (Clear)',
        buffer = bufnr,
        command = function() vim.lsp.buf.clear_references() end,
      })
    end
  end
  rvim.augroup(AUGROUP, cmds)
end

-----------------------------------------------------------------------------//
-- Mappings
-----------------------------------------------------------------------------//
local function with_desc(desc) return { buffer = 0, desc = desc } end
local function setup_mappings(client)
  if not client == nil then return end

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

-----------------------------------------------------------------------------//
-- LSP SETUP/TEARDOWN
-----------------------------------------------------------------------------//

local function setup_plugins(client, bufnr)
  -- vim-illuminate
  if rvim.lsp.document_highlight then
    local status_ok, illuminate = rvim.safe_require('illuminate')
    if not status_ok then return end
    illuminate.on_attach(client)
  end
  -- nvim-navic
  local ok, navic = pcall(require, 'nvim-navic')
  if ok and client.server_capabilities.documentSymbolProvider then navic.attach(client, bufnr) end
end

local function setup_capabilities()
  local snippet = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' },
  }
  local code_action = {
    dynamicRegistration = false,
    codeActionLiteralSupport = {
      codeActionKind = {
        valueSet = (function()
          local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
          table.sort(res)
          return res
        end)(),
      },
    },
  }
  local fold = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  return snippet, code_action, fold
end

local function global_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local snippet_support, code_action_support, folding_range_support = setup_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = snippet_support
  capabilities.textDocument.codeAction = code_action_support
  capabilities.textDocument.foldingRange = folding_range_support
  local ok, cmp_nvim_lsp = rvim.safe_require('cmp_nvim_lsp')
  if ok then cmp_nvim_lsp.update_capabilities(capabilities) end

  return capabilities
end

-- This function allows reading a per project "settings.json" file in the `.vim` directory of the project.
---@param client table<string, any>
---@return boolean
function rvim.lsp.on_init(client)
  local path = client.workspace_folders[1].name
  local config_path = path .. '/.vim/settings.json'
  if fn.filereadable(config_path) == 0 then return true end
  local ok, json = pcall(fn.readfile, config_path)
  if not ok then return true end
  local overrides = vim.json.decode(table.concat(json, '\n'))
  for name, config in pairs(overrides) do
    if name == client.name then
      local original = client.config
      client.config = vim.tbl_deep_extend('force', original, config)
      client.notify('workspace/didChangeConfiguration')
    end
  end
  return true
end

---Add buffer local mappings, autocommands, tagfunc etc for attaching servers
---@param client table lsp client
---@param bufnr number
function rvim.lsp.on_attach(client, bufnr)
  setup_autocommands(client, bufnr)
  setup_plugins(client, bufnr)
  setup_mappings(client)
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  if client.server_capabilities.documentFormattingProvider then
    vim.bo[bufnr].formatexpr = 'v:lua.vim.lsp.formatexpr()'
  end
end

function rvim.lsp.get_global_opts()
  return {
    on_attach = rvim.lsp.on_attach,
    on_init = rvim.lsp.on_init,
    capabilities = global_capabilities(),
  }
end

rvim.augroup('LspSetupCommands', {
  {
    event = 'LspAttach',
    desc = 'setup the language server autocommands',
    command = function(args)
      local bufnr = args.buf
      -- if the buffer is invalid we should not try and attach to it
      if not api.nvim_buf_is_valid(args.buf) or not args.data then return end
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      rvim.lsp.on_attach(client, bufnr)
    end,
  },
  {
    event = 'LspDetach',
    desc = 'Clean up after detached LSP',
    command = function(args) api.nvim_clear_autocmds({ group = AUGROUP, buffer = args.buf }) end,
  },
})
-----------------------------------------------------------------------------//
-- Commands
-----------------------------------------------------------------------------//
local command = rvim.command

command('LspFormat', function() require('user.utils.lsp').format() end)

-- A helper function to auto-update the quickfix list when new diagnostics come
-- in and close it once everything is resolved. This functionality only runs whilst
-- the list is open.
-- similar functionality is provided by: https://github.com/onsails/diaglist.nvim
local function make_diagnostic_qf_updater()
  local cmd_id = nil
  return function()
    if not api.nvim_buf_is_valid(0) then return end
    pcall(vim.diagnostic.setqflist, { open = false })
    rvim.toggle_list('quickfix')
    if not rvim.is_vim_list_open() and cmd_id then
      api.nvim_del_autocmd(cmd_id)
      cmd_id = nil
    end
    if cmd_id then return end
    cmd_id = api.nvim_create_autocmd('DiagnosticChanged', {
      callback = function()
        if rvim.is_vim_list_open() then
          pcall(vim.diagnostic.setqflist, { open = false })
          if #fn.getqflist() == 0 then rvim.toggle_list('quickfix') end
        end
      end,
    })
  end
end

command('LspDiagnostics', make_diagnostic_qf_updater())
rvim.nnoremap('<leader>ll', '<Cmd>LspDiagnostics<CR>', 'lsp: toggle quickfix diagnostics')

-----------------------------------------------------------------------------//
-- Signs
-----------------------------------------------------------------------------//
local function sign(opts)
  fn.sign_define(opts.highlight, {
    text = opts.icon,
    texthl = opts.highlight,
    linehl = fmt('%sLine', opts.highlight),
    culhl = opts.highlight .. 'Line',
  })
end

sign({ highlight = 'DiagnosticSignError', icon = icons.lsp.error })
sign({ highlight = 'DiagnosticSignWarn', icon = icons.lsp.warn })
sign({ highlight = 'DiagnosticSignInfo', icon = icons.lsp.info })
sign({ highlight = 'DiagnosticSignHint', icon = icons.lsp.hint })
-----------------------------------------------------------------------------//
-- Handler Overrides
-----------------------------------------------------------------------------//
--[[
This section overrides the default diagnostic handlers for signs and virtual text so that only
the most severe diagnostic is shown per line
--]]

local ns = api.nvim_create_namespace('severe-diagnostics')

--- Restricts nvim's diagnostic signs to only the single most severe one per line
--- @see `:help vim.diagnostic`
local function max_diagnostic(callback)
  return function(_, bufnr, _, opts)
    -- Get all diagnostics from the whole buffer rather than just the
    -- diagnostics passed to the handler
    local diagnostics = vim.diagnostic.get(bufnr)
    -- Find the "worst" diagnostic per line
    local max_severity_per_line = {}
    for _, d in pairs(diagnostics) do
      local m = max_severity_per_line[d.lnum]
      if not m or d.severity < m.severity then max_severity_per_line[d.lnum] = d end
    end
    -- Pass the filtered diagnostics (with our custom namespace) to
    -- the original handler
    callback(ns, bufnr, vim.tbl_values(max_severity_per_line), opts)
  end
end

local signs_handler = diagnostic.handlers.signs
diagnostic.handlers.signs = vim.tbl_extend('force', signs_handler, {
  show = max_diagnostic(signs_handler.show),
  hide = function(_, bufnr) signs_handler.hide(ns, bufnr) end,
})

local virt_text_handler = diagnostic.handlers.virtual_text
diagnostic.handlers.virtual_text = vim.tbl_extend('force', virt_text_handler, {
  show = max_diagnostic(virt_text_handler.show),
  hide = function(_, bufnr) virt_text_handler.hide(ns, bufnr) end,
})

-----------------------------------------------------------------------------//
-- Diagnostic Configuration
-----------------------------------------------------------------------------//
local max_width = math.min(math.floor(vim.o.columns * 0.7), 100)
local max_height = math.min(math.floor(vim.o.lines * 0.3), 30)

local diagnostics = rvim.lsp.diagnostics
local float = rvim.lsp.diagnostics.float

diagnostic.config({
  signs = { active = diagnostics.signs.active, values = icons.lsp },
  underline = diagnostics.underline,
  update_in_insert = diagnostics.update_in_insert,
  severity_sort = diagnostics.severity_sort,
  virtual_text = {
    prefix = '',
    spacing = diagnostics.virtual_text_spacing,
    format = function(d)
      local level = diagnostic.severity[d.severity]
      return fmt('%s %s', icons.lsp[level:lower()], d.message)
    end,
  },
  float = vim.tbl_deep_extend('keep', {
    max_width = max_width,
    max_height = max_height,
    prefix = function(diag, i, _)
      local level = diagnostic.severity[diag.severity]
      local prefix = fmt('%d. %s ', i, icons.lsp[level:lower()])
      return prefix, 'Diagnostic' .. level:gsub('^%l', string.upper)
    end,
  }, float),
})

-- NOTE: the hover handler returns the bufnr,winnr so can be used for mappings
lsp.handlers['textDocument/hover'] =
  lsp.with(lsp.handlers.hover, { border = border, max_width = max_width, max_height = max_height })

lsp.handlers['textDocument/signatureHelp'] = lsp.with(lsp.handlers.signature_help, {
  border = border,
  max_width = max_width,
  max_height = max_height,
})

lsp.handlers['window/showMessage'] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local lvl = ({ 'ERROR', 'WARN', 'INFO', 'DEBUG' })[result.type]
  vim.notify(result.message, lvl, {
    title = 'LSP | ' .. client.name,
    timeout = 8000,
    keep = function() return lvl == 'ERROR' or lvl == 'WARN' end,
  })
end

require('user.lsp.null-ls').setup()

-- Generate templates
local utils = require('user.utils')
local templates = rvim.lsp.templates_dir
if
  not utils.is_directory(templates) or vim.fn.filereadable(join_paths(templates, 'lua.lua')) ~= 1
then
  require('user.lsp.templates').generate_templates()
end
