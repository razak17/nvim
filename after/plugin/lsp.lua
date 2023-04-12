if not rvim then return end

rvim.lsp.templates_dir = join_paths(vim.fn.stdpath('data'), 'site', 'after', 'ftplugin')

local lsp, fn, api, fmt = vim.lsp, vim.fn, vim.api, string.format
local L, S = vim.lsp.log_levels, vim.diagnostic.severity

local diagnostic = vim.diagnostic
local augroup, icons, border = rvim.augroup, rvim.ui.codicons.lsp, rvim.ui.current.border

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

---@param client lsp.Client
---@param buf integer
local function setup_autocommands(client, buf)
  if client.server_capabilities[provider.HOVER] then
    augroup(('LspHoverDiagnostics%d'):format(buf), {
      event = { 'CursorHold' },
      buffer = buf,
      desc = 'LSP: Show diagnostics',
      command = function(args)
        if not rvim.lsp.hover_diagnostics then return end
        if vim.b.lsp_hover_win and api.nvim_win_is_valid(vim.b.lsp_hover_win) then return end
        vim.diagnostic.open_float(args.buf, { scope = 'line' })
      end,
    })
  end

  if client.server_capabilities[provider.FORMATTING] then
    augroup(('LspFormatting%d'):format(buf), {
      event = 'BufWritePre',
      buffer = buf,
      desc = 'LSP: Format on save',
      command = function(args)
        local excluded = rvim.find_string(format_exclusions.format_on_save, vim.bo.ft)
        if not excluded and not vim.g.formatting_disabled and not vim.b[buf].formatting_disabled then
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
      command = function() lsp.codelens.refresh() end,
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
  if vim.tbl_contains({ 'vim', 'help' }, filetype) then return vim.cmd('h ' .. vim.fn.expand('<cword>')) end
  if vim.tbl_contains({ 'man' }, filetype) then return vim.cmd('Man ' .. vim.fn.expand('<cword>')) end
  if vim.fn.expand('%:t') == 'Cargo.toml' then return require('crates').show_popup() end
  if vim.bo.ft == 'rust' then return require('rust-tools').hover_actions.hover_actions() end
  vim.lsp.buf.hover()
end

local function setup_mappings(client, bufnr)
  local mappings = {
    { 'n', '<leader>lk', function() vim.diagnostic.goto_prev({ float = false }) end, desc = 'go to prev diagnostic' },
    { 'n', '<leader>lj', function() vim.diagnostic.goto_next({ float = false }) end, desc = 'go to next diagnostic' },
    { { 'n', 'x' }, '<leader>la', lsp.buf.code_action, desc = 'code action', capability = provider.CODEACTIONS },
    { 'n', '<leader>lf', format, desc = 'format buffer', capability = provider.FORMATTING },
    { 'n', 'K', show_documentation, desc = 'hover', capability = provider.HOVER },
    -- stylua: ignore
    { 'n', 'gd', lsp.buf.definition, desc = 'definition', capability = provider.DEFINITION, exclude = { 'typescript', 'typescriptreact' }  },
    { 'n', 'gr', lsp.buf.references, desc = 'references', capability = provider.REFERENCES },
    { 'n', 'gi', lsp.buf.implementation, desc = 'implementation', capability = provider.REFERENCES },
    { 'n', 'gI', lsp.buf.incoming_calls, desc = 'incoming calls', capability = provider.REFERENCES },
    { 'n', 'gt', lsp.buf.type_definition, desc = 'go to type definition', capability = provider.DEFINITION },
    { 'n', '<leader>lc', lsp.codelens.run, desc = 'run code lens', capability = provider.CODELENS },
    { 'n', '<leader>lr', lsp.buf.rename, desc = 'rename', capability = provider.RENAME },
    { 'n', '<leader>lL', vim.diagnostic.setloclist, desc = 'toggle loclist diagnostics' },
    { 'n', '<leader>lG', '<Cmd>LspGenerateTemplates<CR>', desc = 'generate templates' },
    { 'n', '<leader>lD', '<Cmd>LspRemoveTemplates<CR>', desc = 'delete templates' },
    { 'n', '<leader>li', '<Cmd>LspInfo<CR>', desc = 'lsp info' },
    { 'n', '<leader>ltv', '<Cmd>ToggleVirtualText<CR>', desc = 'toggle virtual text' },
    { 'n', '<leader>ltl', '<Cmd>ToggleVirtualLines<CR>', desc = 'toggle virtual lines' },
  }

  rvim.foreach(function(m)
    if
      (not m.exclude or not vim.tbl_contains(m.exclude, vim.bo[bufnr].ft))
      and (not m.capability or client.server_capabilities[m.capability])
    then
      map(m[1], m[2], m[3], { buffer = bufnr, desc = fmt('lsp: %s', m.desc) })
    end
  end, mappings)

  if client.name == 'tsserver' then
    local actions = require('typescript').actions
    local typescript_mappings = {
      { 'n', 'gd', '<Cmd>TypescriptGoToSourceDefinition<CR>', desc = 'go to source definition' },
      { 'n', '<localleader>tr', '<Cmd>TypescriptRenameFile<CR>', desc = 'rename file' },
      { 'n', '<localleader>tf', actions.fixAll, desc = 'fix all' },
      { 'n', '<localleader>tia', actions.addMissingImports, desc = 'add missing' },
      { 'n', '<localleader>tio', actions.organizeImports, desc = 'organize' },
      { 'n', '<localleader>tix', actions.removeUnused, desc = 'remove unused' },
    }
    rvim.foreach(
      function(m) map(m[1], m[2], m[3], { buffer = bufnr, desc = fmt('typescript: %s', m.desc) }) end,
      typescript_mappings
    )
  end

  if client.name == 'rust_analyzer' then
    local rust_mappings = {
      { 'n', '<localleader>rh', '<Cmd>RustToggleInlayHints<CR>', desc = 'toggle hints' },
      { 'n', '<localleader>rr', '<Cmd>RustRunnables<CR>', desc = 'runnables' },
      { 'n', '<localleader>rt', '<Cmd>lua _CARGO_TEST()<CR>', desc = 'cargo test' },
      { 'n', '<localleader>rm', '<Cmd>RustExpandMacro<CR>', desc = 'expand cargo' },
      { 'n', '<localleader>rc', '<Cmd>RustOpenCargo<CR>', desc = 'open cargo' },
      { 'n', '<localleader>rp', '<Cmd>RustParentModule<CR>', desc = 'parent module' },
      { 'n', '<localleader>rd', '<Cmd>RustDebuggables<CR>', desc = 'debuggables' },
      { 'n', '<localleader>rv', '<Cmd>RustViewCrateGraph<CR>', desc = 'view crate graph' },
      -- stylua: ignore
      { 'n', '<localleader>rR', "<Cmd>lua require('rust-tools/workspace_refresh')._reload_workspace_from_cargo_toml()<CR>", desc = 'rust-tools: reload workspace' },
      { 'n', '<localleader>ro', '<Cmd>RustOpenExternalDocs<CR>', desc = 'rust-tools: open external docs' },
    }
    rvim.foreach(
      function(m) map(m[1], m[2], m[3], { buffer = bufnr, desc = fmt('rust-tools: %s', m.desc) }) end,
      rust_mappings
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
  -- lsp-inlayhints
  local hints_ok, hints = rvim.pcall(require, 'lsp-inlayhints')
  if hints_ok and client.name ~= 'tsserver' then hints.on_attach(client, bufnr) end
  -- twoslash-queries
  local twoslash_ok, twoslash = rvim.pcall(require, 'twoslash-queries')
  if twoslash_ok and client.name == 'tsserver' then twoslash.attach(client, bufnr) end
end

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

command('LspGenerateTemplates', function() require('user.lsp.templates').generate_templates() end)

command('LspRemoveTemplates', function()
  require('user.lsp.templates').remove_template_files()
  vim.notify('Templates have been removed', 'info', { title = 'Lsp' })
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
  signs = {
    severity = { min = S.WARN },
  },
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
    config = vim.tbl_extend('force', config, {
      virtual_text = {
        severity = { min = S.WARN },
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
    if type(config.virtual_text) == 'table' then config = vim.tbl_extend('force', config, { virtual_text = false }) end
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
if fn.filereadable(join_paths(rvim.lsp.templates_dir, 'lua.lua')) ~= 1 then vim.cmd('LspGenerateTemplates') end
