if not rvim or vim.env.RVIM_LSP_ENABLED == '0' or vim.env.RVIM_PLUGINS_ENABLED == '0' then return end

rvim.lsp.config_file = join_paths(vim.fn.stdpath('config'), 'after', 'plugin', 'lspconfig.lua')

local lsp, fn, api, fmt = vim.lsp, vim.fn, vim.api, string.format
local L = vim.lsp.log_levels

local diagnostic = vim.diagnostic
local augroup, icons, border = rvim.augroup, rvim.ui.codicons.lsp, rvim.ui.current.border

local format_exclusions = {
  format_on_save = { 'zsh' },
  servers = {
    lua = { 'lua_ls' },
    go = { 'null-ls' },
    proto = { 'null-ls' },
    html = { 'html' },
    javascript = { 'quick_lint_js', 'vtsls' },
    json = { 'jsonls' },
    typescript = { 'vtsls' },
    typescriptreact = { 'vtsls' },
    javascriptreact = { 'vtsls' },
  },
}

if vim.env.DEVELOPING then lsp.set_log_level(L.DEBUG) end

----------------------------------------------------------------------------------------------------
-- Autocommands
----------------------------------------------------------------------------------------------------
---@enum
local provider = {
  HOVER = 'hoverProvider',
  RENAME = 'renameProvider',
  CODELENS = 'codeLensProvider',
  CODEACTIONS = 'codeActionProvider',
  FORMATTING = 'documentFormattingProvider',
  REFERENCES = 'documentHighlightProvider',
  DEFINITION = 'definitionProvider',
}

local function formatting_filter(client)
  local exceptions = (format_exclusions.servers)[vim.bo.filetype]
  if not exceptions then return true end
  return not vim.tbl_contains(exceptions, client.name)
end

---@param opts {bufnr: integer, async: boolean, filter: fun(lsp.Client): boolean}
local function format(opts)
  opts = opts or {}
  lsp.buf.format({ bufnr = opts.bufnr, async = opts.async, filter = formatting_filter })
end

----------------------------------------------------------------------------------------------------
--  Related Locations
----------------------------------------------------------------------------------------------------
-- This relates to https://github.com/neovim/neovim/issues/19649#issuecomment-1327287313
-- neovim does not currently correctly report the related locations for diagnostics.
-- TODO: once a PR for this is merged delete this workaround

local function show_related_locations(diag)
  local related_info = diag.relatedInformation
  if not related_info or #related_info == 0 then return diag end
  for _, info in ipairs(related_info) do
    diag.message = ('%s\n%s(%d:%d)%s'):format(
      diag.message,
      fn.fnamemodify(vim.uri_to_fname(info.location.uri), ':p:.'),
      info.location.range.start.line + 1,
      info.location.range.start.character + 1,
      not rvim.falsy(info.message) and (': %s'):format(info.message) or ''
    )
  end
  return diag
end

local handler = lsp.handlers['textDocument/publishDiagnostics']
---@diagnostic disable-next-line: duplicate-set-field
lsp.handlers['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
  result.diagnostics = vim.tbl_map(show_related_locations, result.diagnostics)
  handler(err, result, ctx, config)
end

----------------------------------------------------------------------------------------------------
-- Mappings
----------------------------------------------------------------------------------------------------
local function show_documentation()
  local filetype = vim.bo.filetype
  if vim.tbl_contains({ 'help' }, filetype) then return vim.cmd('h ' .. vim.fn.expand('<cword>')) end
  if vim.tbl_contains({ 'man' }, filetype) then return vim.cmd('Man ' .. vim.fn.expand('<cword>')) end
  vim.lsp.buf.hover()
end

---Setup mapping when an lsp attaches to a buffer
---@param client lsp.Client
---@param bufnr integer
local function setup_mappings(client, bufnr)
  local mappings = {
    { 'n', '<leader>lk', function() vim.diagnostic.goto_prev({ float = false }) end, desc = 'go to prev diagnostic' },
    { 'n', '<leader>lj', function() vim.diagnostic.goto_next({ float = false }) end, desc = 'go to next diagnostic' },
    { { 'n', 'x' }, '<leader>la', lsp.buf.code_action, desc = 'code action', capability = provider.CODEACTIONS },
    { 'n', '<leader>lf', format, desc = 'format buffer', capability = provider.FORMATTING },
    { 'n', 'K', show_documentation, desc = 'hover', capability = provider.HOVER, exclude_ft = { 'rust', 'toml' } },
    { 'n', 'gd', lsp.buf.definition, desc = 'definition', capability = provider.DEFINITION, exclude = { 'vtsls' } },
    { 'n', 'gr', lsp.buf.references, desc = 'references', capability = provider.REFERENCES },
    { 'n', 'gi', lsp.buf.implementation, desc = 'implementation', capability = provider.REFERENCES },
    { 'n', 'gI', lsp.buf.incoming_calls, desc = 'incoming calls', capability = provider.REFERENCES },
    { 'n', 'gt', lsp.buf.type_definition, desc = 'go to type definition', capability = provider.DEFINITION },
    { 'n', '<leader>lc', lsp.codelens.run, desc = 'run code lens', capability = provider.CODELENS },
    { 'n', '<leader>lr', lsp.buf.rename, desc = 'rename', capability = provider.RENAME },
    { 'n', '<leader>lL', vim.diagnostic.setloclist, desc = 'toggle loclist diagnostics' },
    { 'n', '<leader>li', '<Cmd>LspInfo<CR>', desc = 'lsp info' },
    { 'n', '<leader>ltv', '<Cmd>ToggleVirtualText<CR>', desc = 'toggle virtual text' },
    { 'n', '<leader>ltl', '<Cmd>ToggleVirtualLines<CR>', desc = 'toggle virtual lines' },
    { 'n', '<leader>lts', '<Cmd>ToggleSigns<CR>', desc = 'toggle signs' },
  }

  rvim.foreach(function(m)
    if
      (not m.exclude or not vim.tbl_contains(m.exclude, vim.bo[bufnr].ft))
      and (not m.exclude_ft or not vim.tbl_contains(m.exclude_ft, vim.bo[bufnr].ft))
      and (not m.capability or client.server_capabilities[m.capability])
    then
      map(m[1], m[2], m[3], { buffer = bufnr, desc = fmt('lsp: %s', m.desc) })
    end
  end, mappings)

  if client.name == 'vtsls' then
    require('which-key').register({ ['<localleader>t'] = { name = 'Typescript', i = 'Imports' } })

    local vtsls_mappings = {
      { 'n', 'gd', '<Cmd>VtsExec goto_source_definition<CR>', desc = 'go to source definition' },
      { 'n', '<localleader>tr', '<Cmd>VtsExec rename_file<CR>', desc = 'rename file' },
      { 'n', '<localleader>tf', '<Cmd>VtsExec fix_all<CR>', desc = 'fix all' },
      { 'n', '<localleader>tia', '<Cmd>VtsExec add_missing_imports<CR>', desc = 'add missing' },
      { 'n', '<localleader>tio', '<Cmd>VtsExec organize_imports<CR>', desc = 'organize' },
      { 'n', '<localleader>tix', '<Cmd>VtsExec remove_unused_imports<CR>', desc = 'remove unused' },
    }
    rvim.foreach(
      function(m) map(m[1], m[2], m[3], { buffer = bufnr, desc = fmt('%s: %s', 'vtsls', m.desc) }) end,
      vtsls_mappings
    )
  end
end

----------------------------------------------------------------------------------------------------
-- LSP SETUP/TEARDOWN
----------------------------------------------------------------------------------------------------

---@alias ClientOverrides {on_attach: fun(client: lsp.Client, bufnr: number), semantic_tokens: fun(bufnr: number, client: lsp.Client, token: table)}

--- A set of custom overrides for specific lsp clients
--- This is a way of adding functionality for specific lsps
--- without putting all this logic in the general on_attach function
---@type {[string]: ClientOverrides}
local client_overrides = {
  vtsls = {
    semantic_tokens = function(bufnr, client, token)
      if token.type == 'variable' and token.modifiers['local'] and not token.modifiers.readonly then
        lsp.semantic_tokens.highlight_token(token, bufnr, client.id, '@danger')
      end
    end,
  },
}

---@param client lsp.Client
---@param bufnr number
local function setup_semantic_tokens(client, bufnr)
  local overrides = client_overrides[client.name]
  if not overrides or not overrides.semantic_tokens then return end
  augroup(fmt('LspSemanticTokens%s', client.name), {
    event = 'LspTokenUpdate',
    buffer = bufnr,
    desc = fmt('Configure the semantic tokens for the %s', client.name),
    command = function(args) overrides.semantic_tokens(args.buf, client, args.data.token) end,
  })
end

---@param client lsp.Client
---@param buf integer
local function setup_autocommands(client, buf)
  if client.server_capabilities[provider.HOVER] then
    augroup(('LspHoverDiagnostics%d'):format(buf), {
      event = { 'CursorHold' },
      buffer = buf,
      desc = 'LSP: Show diagnostics',
      command = function()
        if not rvim.lsp.hover_diagnostics then return end
        if vim.b.lsp_hover_win and api.nvim_win_is_valid(vim.b.lsp_hover_win) then return end
        vim.diagnostic.open_float({ scope = 'line' })
      end,
    })
  end

  if client.server_capabilities[provider.FORMATTING] then
    augroup(('LspFormatting%d'):format(buf), {
      event = 'BufWritePre',
      buffer = buf,
      desc = 'LSP: Format on save',
      command = function(args)
        if not vim.g.formatting_disabled and not vim.b[buf].formatting_disabled then
          local clients = vim.tbl_filter(
            function(c) return c.server_capabilities[provider.FORMATTING] end,
            lsp.get_active_clients({ buffer = buf })
          )
          if #clients >= 1 then format({ bufnr = args.buf, async = #clients == 1 }) end
        end
      end,
    })
  end

  if client.server_capabilities[provider.CODELENS] then
    augroup(('LspCodeLens%d'):format(buf), {
      event = { 'BufEnter', 'InsertLeave', 'BufWritePost' },
      desc = 'LSP: Code Lens',
      buffer = buf,
      -- call via vimscript so that errors are silenced
      command = 'silent! lua vim.lsp.codelens.refresh()',
    })
  end

  if client.server_capabilities[provider.REFERENCES] then
    augroup(('LspReferences%d'):format(buf), {
      event = { 'CursorHold', 'CursorHoldI' },
      buffer = buf,
      desc = 'LSP: References',
      command = function() lsp.buf.document_highlight() end,
    }, {
      event = 'CursorMoved',
      desc = 'LSP: References Clear',
      buffer = buf,
      command = function() lsp.buf.clear_references() end,
    })
  end
end

-- Add buffer local mappings, autocommands etc for attaching servers
-- this runs for each client because they have different capabilities so each time one
-- attaches it might enable autocommands or mappings that the previous client did not support
---@param client lsp.Client the lsp client
---@param bufnr number
local function on_attach(client, bufnr)
  setup_autocommands(client, bufnr)
  setup_mappings(client, bufnr)
  setup_semantic_tokens(client, bufnr)
  api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

augroup('LspSetupCommands', {
  event = { 'LspAttach' },
  desc = 'setup the language server autocommands',
  command = function(args)
    local client = lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    on_attach(client, args.buf)
    local overrides = client_overrides[client.name]
    if not overrides or not overrides.on_attach then return end
    overrides.on_attach(client, args.buf)
  end,
}, {
  event = 'DiagnosticChanged',
  desc = 'Update the diagnostic locations',
  command = function(args)
    diagnostic.setloclist({ open = false })
    if #args.data.diagnostics == 0 then vim.cmd('silent! lclose') end
  end,
})

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
local command = rvim.command

command('LspGenerateTemplates', function() require('user.lsp.templates').generate_config_file() end)

command('LspRemoveTemplates', function()
  require('user.lsp.templates').remove_template_files()
  vim.notify('Lsp config file has been removed', 'info', { title = 'Lsp' })
end)
----------------------------------------------------------------------------------------------------
-- Signs
----------------------------------------------------------------------------------------------------
---@param opts {highlight: string, icon: string}
local function sign(opts)
  fn.sign_define(opts.highlight, {
    text = opts.icon,
    texthl = opts.highlight,
    numhl = opts.highlight .. 'Nr' or nil,
    culhl = opts.highlight .. 'CursorNr' or nil,
    linehl = opts.highlight .. 'Line' or nil,
  })
end

sign({ highlight = 'DiagnosticSignError', icon = icons.error })
sign({ highlight = 'DiagnosticSignWarn', icon = icons.warn })
sign({ highlight = 'DiagnosticSignInfo', icon = icons.info })
sign({ highlight = 'DiagnosticSignHint', icon = icons.hint })
----------------------------------------------------------------------------------------------------
-- Diagnostic Configuration
----------------------------------------------------------------------------------------------------
local max_width = math.min(math.floor(vim.o.columns * 0.7), 100)
local max_height = math.min(math.floor(vim.o.lines * 0.3), 30)

diagnostic.config({
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_lines = false,
  virtual_text = false,
  float = {
    max_width = max_width,
    max_height = max_height,
    border = border,
    title = { { '  ', 'DiagnosticFloatTitleIcon' }, { 'Problems  ', 'DiagnosticFloatTitle' } },
    focusable = false,
    scope = 'cursor',
    source = 'if_many',
    prefix = function(diag)
      local level = diagnostic.severity[diag.severity]
      local prefix = fmt('%s ', icons[level:lower()])
      return prefix, 'Diagnostic' .. level:gsub('^%l', string.upper)
    end,
  },
})

local function toggle_virtual_text()
  local config = vim.diagnostic.config()
  if type(config.virtual_text) == 'boolean' then
    config = vim.tbl_extend('force', config, { virtual_text = { prefix = '', spacing = 1 } })
    if type(config.virtual_lines) == 'table' then
      config = vim.tbl_extend('force', config, { virtual_lines = false })
      rvim.lsp.hover_diagnostics = true
    end
  else
    config = vim.tbl_extend('force', config, { virtual_text = false })
  end
  vim.diagnostic.config(config)
end
command('ToggleVirtualText', toggle_virtual_text)

local function toggle_virtual_lines()
  local config = vim.diagnostic.config()
  if type(config.virtual_lines) == 'boolean' then
    config = vim.tbl_extend('force', config, { virtual_lines = { only_current_line = true } })
    if type(config.virtual_text) == 'table' then config = vim.tbl_extend('force', config, { virtual_text = false }) end
    rvim.lsp.hover_diagnostics = false
  else
    config = vim.tbl_extend('force', config, { virtual_lines = false })
    rvim.lsp.hover_diagnostics = true
  end
  vim.diagnostic.config(config)
end
command('ToggleVirtualLines', toggle_virtual_lines)

local function toggle_signs()
  rvim.lsp.signs.enable = not rvim.lsp.signs.enable
  vim.cmd('edit | silent! wall')
end
rvim.command('ToggleSigns', toggle_signs)

map('n', '<leader>lG', '<Cmd>LspGenerateTemplates<CR>', { desc = 'generate setup file' })
map('n', '<leader>lD', '<Cmd>LspRemoveTemplates<CR>', { desc = 'delete setup file' })
map('n', '<leader>lO', '<Cmd>edit ' .. rvim.lsp.config_file .. '<CR>', { desc = 'open lspsetup file' })

lsp.handlers['textDocument/hover'] = function(...)
  local hover_handler = lsp.with(lsp.handlers.hover, {
    border = border,
    max_width = max_width,
    max_height = max_height,
  })
  vim.b.lsp_hover_buf, vim.b.lsp_hover_win = hover_handler(...)
end

-- Generate templates
if fn.filereadable(rvim.lsp.config_file) ~= 1 then vim.defer_fn(function() vim.cmd('LspGenerateTemplates') end, 1) end
