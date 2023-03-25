if not rvim then return end

rvim.lsp.templates_dir = join_paths(rvim.get_runtime_dir(), 'site', 'after', 'ftplugin')

local lsp, fn, api, fmt = vim.lsp, vim.fn, vim.api, string.format
local b = vim.b --[[@rvim table<string, any>]]
local L = lsp.log_levels

local icons = rvim.ui.codicons.lsp
local border = rvim.ui.current.border
local diagnostic = vim.diagnostic

local format_exclusions = {
  format_on_save = { 'zsh' },
  servers = {
    lua = { 'lua_ls' },
    go = { 'null-ls' },
    proto = { 'null-ls' },
    html = { 'html' },
    javascript = { 'quick_lint_js', 'tsserver' },
    typescript = { 'tsserver' },
    typescriptreact = { 'tsserver' },
    javascriptreact = { 'tsserver' },
    sql = { 'sqls' },
  },
}

if vim.env.DEVELOPING then lsp.set_log_level(L.DEBUG) end

----------------------------------------------------------------------------------------------------
-- Autocommands
----------------------------------------------------------------------------------------------------
local FEATURES = {
  DIAGNOSTICS = { name = 'diagnostics' },
  CODELENS = { name = 'codelens', provider = 'codeLensProvider' },
  FORMATTING = { name = 'formatting', provider = 'documentFormattingProvider' },
  REFERENCES = { name = 'references', provider = 'documentHighlightProvider' },
}

---@param bufnr integer
---@param capability string
---@return table[]
local function clients_by_capability(bufnr, capability)
  return vim.tbl_filter(
    function(c) return c.server_capabilities[capability] end,
    lsp.get_active_clients({ buffer = bufnr })
  )
end

--- Create augroups for each LSP feature and track which capabilities each client
--- registers in a buffer local table
---@param bufnr integer
---@param client lsp.Client
---@param events { [string]: { clients: number[], group_id: number? } }
---@return fun(feature: {provider: string, name: string}, commands: fun(string): ...)
local function augroup_factory(bufnr, client, events)
  return function(feature, commands)
    local provider, name = feature.provider, feature.name
    if not provider or client.server_capabilities[provider] then
      events[name].group_id =
        rvim.augroup(fmt('LspCommands_%d_%s', bufnr, name), commands(provider))
      table.insert(events[name].clients, client.id)
    end
  end
end

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

--- Add lsp autocommands
---@param client lsp.Client
---@param bufnr number
local function setup_autocommands(client, bufnr)
  if not client then
    local msg = fmt('Unable to setup LSP autocommands, client for %d is missing', bufnr)
    return vim.notify(msg, 'error', { title = 'LSP Setup' })
  end

  local events = vim.F.if_nil(b.lsp_events, {
    [FEATURES.CODELENS.name] = { clients = {}, group_id = nil },
    [FEATURES.FORMATTING.name] = { clients = {}, group_id = nil },
    [FEATURES.DIAGNOSTICS.name] = { clients = {}, group_id = nil },
    [FEATURES.REFERENCES.name] = { clients = {}, group_id = nil },
  })

  local augroup = augroup_factory(bufnr, client, events)

  augroup(FEATURES.DIAGNOSTICS, function()
    return {
      event = { 'CursorHold' },
      buffer = bufnr,
      desc = 'LSP: Show diagnostics',
      command = function(args)
        if not rvim.lsp.hover_diagnostics then return end
        if vim.b.lsp_hover_win and api.nvim_win_is_valid(vim.b.lsp_hover_win) then return end
        vim.diagnostic.open_float(args.buf, { scope = 'line' })
      end,
    }
  end)

  augroup(FEATURES.FORMATTING, function(provider)
    return {
      event = 'BufWritePre',
      buffer = bufnr,
      desc = 'LSP: Format on save',
      command = function(args)
        local excluded = rvim.find_string(format_exclusions.format_on_save, vim.bo.ft)
        if not excluded and not vim.g.formatting_disabled and not b.formatting_disabled then
          local clients = clients_by_capability(args.buf, provider)
          if #clients >= 1 then format({ bufnr = args.buf, async = #clients == 1 }) end
        end
      end,
    }
  end)

  augroup(FEATURES.REFERENCES, function()
    return {
      event = { 'CursorHold', 'CursorHoldI' },
      buffer = bufnr,
      desc = 'LSP: References',
      command = function() lsp.buf.document_highlight() end,
    }, {
      event = 'CursorMoved',
      desc = 'LSP: References Clear',
      buffer = bufnr,
      command = function() lsp.buf.clear_references() end,
    }
  end)

  augroup(FEATURES.CODELENS, function()
    return {
      event = { 'BufEnter', 'CursorHold', 'InsertLeave' },
      desc = 'LSP: Code Lens',
      buffer = bufnr,
      command = function() pcall(lsp.codelens.refresh) end,
    }
  end)
  vim.b[bufnr].lsp_events = events
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
  if vim.tbl_contains({ 'vim', 'help' }, filetype) then
    return vim.cmd('h ' .. vim.fn.expand('<cword>'))
  end
  if vim.tbl_contains({ 'man' }, filetype) then
    return vim.cmd('Man ' .. vim.fn.expand('<cword>'))
  end
  if vim.fn.expand('%:t') == 'Cargo.toml' then return require('crates').show_popup() end
  if vim.bo.ft == 'rust' then return require('rust-tools').hover_actions.hover_actions() end
  vim.lsp.buf.hover()
end

local function setup_mappings(client, bufnr)
  local function with_desc(desc, alt)
    return { buffer = bufnr, desc = alt and fmt('%s: %s', alt, desc) or fmt('lsp: %s', desc) }
  end

  map('n', 'K', show_documentation, with_desc('hover'))
  map('n', 'gd', lsp.buf.definition, with_desc('definition'))
  map('n', 'gr', lsp.buf.references, with_desc('references'))
  map('n', 'gi', lsp.buf.implementation, with_desc('go to implementation'))
  map('n', 'gt', lsp.buf.type_definition, with_desc('go to type definition'))
  map('n', 'gI', lsp.buf.incoming_calls, with_desc('incoming calls'))
  -- Leader keymaps
  --------------------------------------------------------------------------------------------------
  map({ 'n', 'x' }, '<leader>la', lsp.buf.code_action, with_desc('code action'))
  map(
    'n',
    '<leader>lk',
    function() vim.diagnostic.goto_prev({ float = false }) end,
    with_desc('prev diagnostic')
  )
  map(
    'n',
    '<leader>lj',
    function() vim.diagnostic.goto_next({ float = false }) end,
    with_desc('next diagnostic')
  )
  map('n', '<leader>lL', vim.diagnostic.setloclist, with_desc('toggle loclist diagnostics'))
  map('n', '<leader>lc', lsp.codelens.run, with_desc('run code lens'))
  map('n', '<leader>lr', lsp.buf.rename, with_desc('rename'))
  -- Templates
  map('n', '<leader>lG', function()
    require('user.lsp.templates').generate_templates()
    vim.notify('Templates have been generated', nil, { title = 'Lsp' })
  end, { desc = 'lsp: generate templates' })
  map('n', '<leader>lD', function()
    require('user.lsp.templates').remove_template_files()
    vim.notify('Templates have been removed', nil, { title = 'Lsp' })
  end, { desc = 'lsp: delete templates' })
  -- Others
  map('n', '<leader>li', '<cmd>LspInfo<CR>', with_desc('info'))
  map('n', '<leader>lf', '<cmd>LspFormat<CR>', with_desc('format buffer'))
  map('n', '<leader>ltv', '<cmd>ToggleVirtualText<CR>', with_desc('toggle virtual text'))
  map('n', '<leader>ltl', '<cmd>ToggleVirtualLines<CR>', with_desc('toggle virtual lines'))
  map('n', '<leader>lts', '<cmd>ToggleDiagnosticSigns<CR>', with_desc('toggle  signs'))
  -- Typescript
  if client.name == 'tsserver' then
    local actions = require('typescript').actions
    map('n', 'gd', 'TypescriptGoToSourceDefinition', {
      desc = 'typescript: go to source definition',
    })
    map(
      'n',
      '<localleader>tr',
      '<cmd>TypescriptRenameFile<CR>',
      with_desc('typescript: rename file')
    )
    map('n', '<localleader>tf', actions.fixAll, with_desc('fix all', 'typescript'))
    map('n', '<localleader>tia', actions.addMissingImports, with_desc('add missing', 'typescript'))
    map('n', '<localleader>tio', actions.organizeImports, with_desc('organize', 'typescript'))
    map('n', '<localleader>tix', actions.removeUnused, with_desc('remove unused', 'typescript'))
  end
  -- Rust tools
  if client.name == 'rust_analyzer' then
    map(
      'n',
      '<localleader>rh',
      '<cmd>RustToggleInlayHints<CR>',
      with_desc('toggle hints', 'rust-tools')
    )
    map('n', '<localleader>rr', '<cmd>RustRunnables<CR>', with_desc('runnables', 'rust-tools'))
    map('n', '<localleader>rt', '<cmd>lua _CARGO_TEST()<CR>', with_desc('cargo test', 'rust-tools'))
    map('n', '<localleader>rm', '<cmd>RustExpandMacro<CR>', with_desc('expand cargo', 'rust-tools'))
    map('n', '<localleader>rc', '<cmd>RustOpenCargo<CR>', with_desc('open cargo', 'rust-tools'))
    map(
      'n',
      '<localleader>rp',
      '<cmd>RustParentModule<CR>',
      with_desc('parent module', 'rust-tools')
    )
    map('n', '<localleader>rd', '<cmd>RustDebuggables<CR>', with_desc('debuggables', 'rust-tools'))
    map(
      'n',
      '<localleader>rv',
      '<cmd>RustViewCrateGraph<CR>',
      with_desc('view crate graph', 'rust-tools')
    )
    map(
      'n',
      '<localleader>rR',
      "<cmd>lua require('rust-tools/workspace_refresh')._reload_workspace_from_cargo_toml()<CR>",
      with_desc('reload workspace', 'rust-tools')
    )
    map(
      'n',
      '<localleader>ro',
      '<cmd>RustOpenExternalDocs<CR>',
      with_desc('open external docs', 'rust-tools')
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
  sqls = {
    on_attach = function(client, bufnr) require('sqls').on_attach(client, bufnr) end,
  },
  tsserver = {
    semantic_tokens = function(bufnr, client, token)
      if token.type == 'variable' and token.modifiers['local'] and not token.modifiers.readonly then
        lsp.semantic_tokens.highlight_token(token, bufnr, client.id, '@danger')
      end
    end,
  },
}

---@param client lsp.Client
---@param bufnr number
local function setup_plugins(client, bufnr)
  -- nvim-navic
  local navic_ok, navic = rvim.require('nvim-navic')
  if navic_ok and client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
  -- lsp-inlayhints
  local hints_ok, hints = rvim.require('lsp-inlayhints')
  if hints_ok and client.name ~= 'tsserver' then hints.on_attach(client, bufnr) end
  -- twoslash-queries
  local twoslash_ok, twoslash = rvim.require('twoslash-queries')
  if twoslash_ok and client.name == 'tsserver' then twoslash.attach(client, bufnr) end
end

---@param client lsp.Client
---@param bufnr number
local function setup_semantic_tokens(client, bufnr)
  local overrides = client_overrides[client.name]
  if not overrides or not overrides.semantic_tokens then return end
  rvim.augroup(fmt('LspSemanticTokens%s', client.name), {
    event = 'LspTokenUpdate',
    buffer = bufnr,
    desc = fmt('Configure the semantic tokens for the %s', client.name),
    command = function(args) overrides.semantic_tokens(args.buf, client, args.data.token) end,
  })
end

-- Add buffer local mappings, autocommands etc for attaching servers
-- this runs for each client because they have different capabilities so each time one
-- attaches it might enable autocommands or mappings that the previous client did not support
---@param client lsp.Client the lsp client
---@param bufnr number
local function on_attach(client, bufnr)
  setup_plugins(client, bufnr)
  setup_autocommands(client, bufnr)
  setup_mappings(client, bufnr)
  setup_semantic_tokens(client, bufnr)
  api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

rvim.augroup('LspSetupCommands', {
  event = { 'LspAttach' },
  desc = 'setup the language server autocommands',
  command = function(args)
    local client = lsp.get_client_by_id(args.data.client_id)
    on_attach(client, args.buf)
    local overrides = client_overrides[client.name]
    if not overrides or not overrides.on_attach then return end
    overrides.on_attach(client, args.buf)
  end,
}, {
  event = { 'LspDetach' },
  desc = 'Clean up after detached LSP',
  command = function(args)
    local client_id = args.data.client_id
    if not b.lsp_events or not client_id then return end
    for _, state in pairs(b.lsp_events) do
      if #state.clients == 1 and state.clients[1] == client_id then
        api.nvim_clear_autocmds({ group = state.group_id, buffer = args.buf })
      end
      vim.tbl_filter(function(id) return id ~= client_id end, state.clients)
    end
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

command('LspFormat', function() format({ bufnr = 0, async = false }) end)

----------------------------------------------------------------------------------------------------
-- Signs
----------------------------------------------------------------------------------------------------
local function sign(opts)
  fn.sign_define(opts.highlight, {
    text = opts.icon,
    texthl = opts.highlight,
    linehl = fmt('%sLine', opts.highlight),
    culhl = opts.highlight .. 'Line',
  })
end

local function toggle_diagnostic_signs()
  if rvim.lsp.signs.enable then
    rvim.lsp.signs.enable = false
    sign({ highlight = 'DiagnosticSignError', icon = icons.error })
    sign({ highlight = 'DiagnosticSignWarn', icon = icons.warn })
    sign({ highlight = 'DiagnosticSignInfo', icon = icons.info })
    sign({ highlight = 'DiagnosticSignHint', icon = icons.hint })
  else
    rvim.lsp.signs.enable = true
    sign({ highlight = 'DiagnosticSignError', icon = '' })
    sign({ highlight = 'DiagnosticSignWarn', icon = '' })
    sign({ highlight = 'DiagnosticSignInfo', icon = '' })
    sign({ highlight = 'DiagnosticSignHint', icon = '' })
  end
end
toggle_diagnostic_signs()
command('ToggleDiagnosticSigns', toggle_diagnostic_signs)

----------------------------------------------------------------------------------------------------
-- Diagnostic Configuration
----------------------------------------------------------------------------------------------------
local max_width = math.min(math.floor(vim.o.columns * 0.7), 100)
local max_height = math.min(math.floor(vim.o.lines * 0.3), 30)

diagnostic.config({
  signs = { active = rvim.lsp.signs.active, values = icons },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_lines = false,
  virtual_text = false,
  float = {
    max_width = max_width,
    max_height = max_height,
    border = border,
    header = { ' Problems', 'UnderlinedTitle' },
    focusable = false,
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
    config = vim.tbl_extend('force', config, {
      virtual_text = {
        prefix = '',
        spacing = 1,
        format = function(d)
          local level = diagnostic.severity[d.severity]
          return fmt('%s %s', icons[level:lower()], d.message)
        end,
      },
    })
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
    if type(config.virtual_text) == 'table' then
      config = vim.tbl_extend('force', config, { virtual_text = false })
    end
    rvim.lsp.hover_diagnostics = false
  else
    config = vim.tbl_extend('force', config, { virtual_lines = false })
    rvim.lsp.hover_diagnostics = true
  end
  vim.diagnostic.config(config)
end
command('ToggleVirtualLines', toggle_virtual_lines)

lsp.handlers['textDocument/hover'] = function(...)
  local hover_handler = lsp.with(lsp.handlers.hover, {
    border = border,
    max_width = max_width,
    max_height = max_height,
  })
  vim.b.lsp_hover_buf, vim.b.lsp_hover_win = hover_handler(...)
end

lsp.handlers['textDocument/signatureHelp'] = lsp.with(lsp.handlers.signature_help, {
  border = border,
  max_width = max_width,
  max_height = max_height,
})

lsp.handlers['window/showMessage'] = function(_, result, ctx)
  local client = lsp.get_client_by_id(ctx.client_id)
  local lvl = ({ 'ERROR', 'WARN', 'INFO', 'DEBUG' })[result.type]
  vim.notify(result.message, lvl, {
    title = 'LSP | ' .. client.name,
    timeout = 8000,
    keep = function() return lvl == 'ERROR' or lvl == 'WARN' end,
  })
end

-- Generate templates
local templates = rvim.lsp.templates_dir
if not rvim.is_directory(templates) or fn.filereadable(join_paths(templates, 'lua.lua')) ~= 1 then
  require('user.lsp.templates').generate_templates()
  vim.notify('Templates have been generated', 'info', { title = 'Lsp' })
end
