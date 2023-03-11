-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/plugin/lsp.lua
if not rvim then return end

rvim.lsp.templates_dir = join_paths(rvim.get_runtime_dir(), 'site', 'after', 'ftplugin')

local lsp, fn, api, fmt = vim.lsp, vim.fn, vim.api, string.format
local b = vim.b --[[@rvim table<string, any>]]
local L = lsp.log_levels

local codicons = rvim.ui.codicons
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

---@param buf integer
---@return boolean
local function is_buffer_valid(buf)
  return buf and api.nvim_buf_is_loaded(buf) and api.nvim_buf_is_valid(buf)
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

---@param opts table<string, any>
local function format(opts)
  opts = opts or {}
  lsp.buf.format({
    bufnr = opts.bufnr,
    async = opts.async,
    filter = formatting_filter,
  })
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
      command = function(args)
        if is_buffer_valid(args.buf) then lsp.codelens.refresh() end
      end,
    }
  end)
  vim.b[bufnr].lsp_events = events
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
  local function with_desc(desc) return { buffer = bufnr, desc = desc } end
  if not client == nil then return end
  map('n', 'gl', function()
    local config = rvim.lsp.diagnostics.float
    config.scope = 'line'
    return vim.diagnostic.open_float(config)
  end, with_desc('lsp: line diagnostics'))
  map('n', 'K', show_documentation, with_desc('lsp: hover'))
  map('n', 'gd', lsp.buf.definition, with_desc('lsp: definition'))
  map('n', 'gr', lsp.buf.references, with_desc('lsp: references'))
  map('n', 'gi', lsp.buf.implementation, with_desc('lsp: go to implementation'))
  map('n', 'gt', lsp.buf.type_definition, with_desc('lsp: go to type definition'))
  map('n', 'gI', lsp.buf.incoming_calls, with_desc('lsp: incoming calls'))
  -- Leader keymaps
  --------------------------------------------------------------------------------------------------
  map({ 'n', 'x' }, '<leader>la', lsp.buf.code_action, with_desc('lsp: code action'))
  map(
    'n',
    '<leader>lk',
    function() vim.diagnostic.goto_prev({ float = false }) end,
    with_desc('lsp: prev diagnostic')
  )
  map(
    'n',
    '<leader>lj',
    function() vim.diagnostic.goto_next({ float = false }) end,
    with_desc('lsp: next diagnostic')
  )
  map('n', '<leader>lL', vim.diagnostic.setloclist, with_desc('lsp: toggle loclist diagnostics'))
  map('n', '<leader>lc', lsp.codelens.run, with_desc('lsp: run code lens'))
  map('n', '<leader>lr', lsp.buf.rename, with_desc('lsp: rename'))
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
  map('n', '<leader>li', '<cmd>LspInfo<CR>', with_desc('lsp: info'))
  map('n', '<leader>lf', '<cmd>LspFormat<CR>', with_desc('lsp: format buffer'))
  map('n', '<leader>ll', '<cmd>LspDiagnostics<CR>', with_desc('toggle quickfix diagnostics'))
  map('n', '<leader>ltv', '<cmd>ToggleVirtualText<CR>', with_desc('toggle virtual text'))
  map('n', '<leader>ltl', '<cmd>ToggleVirtualLines<CR>', with_desc('toggle virtual lines'))
  map('n', '<leader>lts', '<cmd>ToggleDiagnosticSigns<CR>', with_desc('toggle  signs'))
  -- Typescript
  if client.name == 'tsserver' then
    local actions = require('typescript').actions
    map(
      'n',
      '<localleader>tr',
      '<cmd>TypescriptRenameFile<CR>',
      with_desc('typescript: rename file')
    )
    map('n', '<localleader>tf', actions.fixAll, with_desc('typescript: fix all'))
    map('n', '<localleader>tia', actions.addMissingImports, with_desc('typescript: add missing'))
    map('n', '<localleader>tio', actions.organizeImports, with_desc('typescript: organize'))
    map('n', '<localleader>tix', actions.removeUnused, with_desc('typescript: remove unused'))
  end
  -- Rust tools
  if client.name == 'rust_analyzer' then
    map(
      'n',
      '<localleader>rh',
      '<cmd>RustToggleInlayHints<CR>',
      with_desc('rust-tools: toggle hints')
    )
    map('n', '<localleader>rr', '<cmd>RustRunnables<CR>', with_desc('rust-tools: runnables'))
    map('n', '<localleader>rt', '<cmd>lua _CARGO_TEST()<CR>', with_desc('rust-tools: cargo test'))
    map('n', '<localleader>rm', '<cmd>RustExpandMacro<CR>', with_desc('rust-tools: expand cargo'))
    map('n', '<localleader>rc', '<cmd>RustOpenCargo<CR>', with_desc('rust-tools: open cargo'))
    map('n', '<localleader>rp', '<cmd>RustParentModule<CR>', with_desc('rust-tools: parent module'))
    map('n', '<localleader>rd', '<cmd>RustDebuggables<CR>', with_desc('rust-tools: debuggables'))
    map(
      'n',
      '<localleader>rv',
      '<cmd>RustViewCrateGraph<CR>',
      with_desc('rust-tools: view crate graph')
    )
    map(
      'n',
      '<localleader>rR',
      "<cmd>lua require('rust-tools/workspace_refresh')._reload_workspace_from_cargo_toml()<CR>",
      with_desc('rust-tools: reload workspace')
    )
    map(
      'n',
      '<localleader>ro',
      '<cmd>RustOpenExternalDocs<CR>',
      with_desc('rust-tools: open external docs')
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
})

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
local command = rvim.command

command('LspFormat', function() format({ bufnr = 0, async = false }) end)

-- A helper function to auto-update the quickfix list when new diagnostics come
-- in and close it once everything is resolved. This functionality only runs whilst
-- the list is open.
-- similar functionality is provided by: https://github.com/onsails/diaglist.nvim
do
  ---@type integer?
  local id
  local TITLE = 'DIAGNOSTICS'
  -- A helper function to auto-update the quickfix list when new diagnostics come
  -- in and close it once everything is resolved. This functionality only runs whilst
  -- the list is open.
  -- similar functionality is provided by: https://github.com/onsails/diaglist.nvim
  local function smart_quickfix_diagnostics()
    if not is_buffer_valid(api.nvim_get_current_buf()) then return end

    diagnostic.setqflist({ open = false, title = TITLE })
    rvim.toggle_qf_list()

    if not rvim.is_vim_list_open() and id then
      api.nvim_del_autocmd(id)
      id = nil
    end

    id = id
      or api.nvim_create_autocmd('DiagnosticChanged', {
        callback = function()
          -- skip QF lists that we did not populate
          if not rvim.is_vim_list_open() or fn.getqflist({ title = 0 }).title ~= TITLE then
            return
          end
          diagnostic.setqflist({ open = false, title = TITLE })
          if #fn.getqflist() == 0 then rvim.toggle_qf_list() end
        end,
      })
  end
  command('LspDiagnostics', smart_quickfix_diagnostics)
end

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
    sign({ highlight = 'DiagnosticSignError', icon = codicons.lsp.error })
    sign({ highlight = 'DiagnosticSignWarn', icon = codicons.lsp.warn })
    sign({ highlight = 'DiagnosticSignInfo', icon = codicons.lsp.info })
    sign({ highlight = 'DiagnosticSignHint', icon = codicons.lsp.hint })
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
  signs = { active = rvim.lsp.signs.active, values = codicons.lsp },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_lines = false,
  virtual_text = false,
  float = {
    max_width = max_width,
    max_height = max_height,
    border = border,
    focusable = false,
    style = 'minimal',
    source = 'always',
    header = '',
    format = function(d)
      local t = vim.deepcopy(d)
      local code = d.code or (d.user_data and d.user_data.lsp.code)
      if code then t.message = string.format('%s [%s]', t.message, code):gsub('1. ', '') end
      return t.message
    end,
    prefix = function(diag, i, _)
      local level = diagnostic.severity[diag.severity]
      local prefix = fmt('%d. %s ', i, codicons.lsp[level:lower()])
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
          return fmt('%s %s', codicons.lsp[level:lower()], d.message)
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
