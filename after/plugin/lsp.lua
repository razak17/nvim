-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/plugin/lsp.lua
if not rvim then return end

local lsp = vim.lsp
local fn = vim.fn
local api = vim.api
local fmt = string.format
local L = lsp.log_levels

local s = rvim.style
local codicons = s.codicons
local border = rvim.style.current.border
local diagnostic = vim.diagnostic
local format_exclusions = rvim.lsp.format_exclusions

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
---@param client table
---@param events table
---@return fun(feature: {provider: string, name: string}, commands: fun(string): Autocommand[])
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
---@param client table<string, any>
---@param bufnr number
local function setup_autocommands(client, bufnr)
  if not client then
    local msg = fmt('Unable to setup LSP autocommands, client for %d is missing', bufnr)
    return vim.notify(msg, 'error', { title = 'LSP Setup' })
  end

  local events = vim.F.if_nil(vim.b.lsp_events, {
    [FEATURES.CODELENS.name] = { clients = {}, group_id = nil },
    [FEATURES.FORMATTING.name] = { clients = {}, group_id = nil },
    [FEATURES.DIAGNOSTICS.name] = { clients = {}, group_id = nil },
    [FEATURES.REFERENCES.name] = { clients = {}, group_id = nil },
  })

  local augroup = augroup_factory(bufnr, client, events)

  augroup(FEATURES.DIAGNOSTICS, function()
    return {
      {
        event = { 'CursorHold' },
        buffer = bufnr,
        desc = 'LSP: Show diagnostics',
        command = function(args)
          if vim.b.lsp_hover_win and api.nvim_win_is_valid(vim.b.lsp_hover_win) then return end
          if rvim.lsp.hover_diagnostics then
            vim.diagnostic.open_float(args.buf, { scope = 'line' })
          end
        end,
      },
    }
  end)

  augroup(FEATURES.FORMATTING, function(provider)
    return {
      {
        event = 'BufWritePre',
        buffer = bufnr,
        desc = 'LSP: Format on save',
        command = function(args)
          local excluded = rvim.find_string(format_exclusions.format_on_save, vim.bo.ft)
          if not excluded and not vim.g.formatting_disabled and not vim.b.formatting_disabled then
            local clients = clients_by_capability(args.buf, provider)
            format({ bufnr = args.buf, async = #clients == 1 })
          end
        end,
      },
    }
  end)

  augroup(FEATURES.REFERENCES, function()
    return {
      {
        event = { 'CursorHold', 'CursorHoldI' },
        buffer = bufnr,
        desc = 'LSP: References',
        command = function() lsp.buf.document_highlight() end,
      },
      {
        event = 'CursorMoved',
        desc = 'LSP: References Clear',
        buffer = bufnr,
        command = function() lsp.buf.clear_references() end,
      },
    }
  end)

  augroup(FEATURES.CODELENS, function()
    return {
      {
        event = { 'BufEnter', 'CursorHold', 'InsertLeave' },
        desc = 'LSP: Code Lens',
        buffer = bufnr,
        command = function() lsp.codelens.refresh() end,
      },
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
  local nnoremap = rvim.nnoremap
  nnoremap('gl', function()
    local config = rvim.lsp.diagnostics.float
    config.scope = 'line'
    return vim.diagnostic.open_float(config)
  end, with_desc('lsp: line diagnostics'))
  nnoremap('K', show_documentation, with_desc('lsp: hover'))
  nnoremap('gd', lsp.buf.definition, with_desc('lsp: definition'))
  nnoremap('gr', lsp.buf.references, with_desc('lsp: references'))
  nnoremap('gi', lsp.buf.implementation, with_desc('lsp: go to implementation'))
  nnoremap('gt', lsp.buf.type_definition, with_desc('lsp: go to type definition'))
  nnoremap('gI', lsp.buf.incoming_calls, with_desc('lsp: incoming calls'))
  -- Leader keymaps
  ----------------------------------------------------------------------------------------------------
  vim.keymap.set({ 'n', 'x' }, '<leader>la', lsp.buf.code_action, with_desc('lsp: code action'))
  nnoremap('<leader>lk', function()
    if rvim.lsp.hover_diagnostics then
      vim.diagnostic.goto_prev({ float = false })
      return
    end
    vim.diagnostic.goto_prev()
  end, with_desc('lsp: go to prev diagnostic'))
  nnoremap('<leader>lj', function()
    if rvim.lsp.hover_diagnostics then
      vim.diagnostic.goto_next({ float = false })
      return
    end
    vim.diagnostic.goto_next()
  end, with_desc('lsp: go to next diagnostic'))
  nnoremap('<leader>lL', vim.diagnostic.setloclist, with_desc('lsp: toggle loclist diagnostics'))
  nnoremap('<leader>lc', lsp.codelens.run, with_desc('lsp: run code lens'))
  nnoremap('<leader>lr', lsp.buf.rename, with_desc('lsp: rename'))
  -- Templates
  nnoremap('<leader>lG', function()
    require('user.lsp.templates').generate_templates()
    vim.notify('Templates have been generated', nil, { title = 'Lsp' })
  end, 'lsp: generate templates')
  nnoremap('<leader>lD', function()
    require('user.lsp.templates').remove_template_files()
    vim.notify('Templates have been removed', nil, { title = 'Lsp' })
  end, 'lsp: delete templates')
  -- Others
  nnoremap('<leader>li', '<cmd>LspInfo<CR>', with_desc('lsp: info'))
  nnoremap('<leader>lf', '<cmd>LspFormat<CR>', with_desc('lsp: format buffer'))
  nnoremap('<leader>ll', '<cmd>LspDiagnostics<CR>', with_desc('toggle quickfix diagnostics'))
  nnoremap('<leader>ltv', '<cmd>ToggleVirtualText<CR>', with_desc('toggle virtual text'))
  nnoremap('<leader>lts', '<cmd>ToggleDiagnosticSigns<CR>', with_desc('toggle  signs'))
  -- Typescript
  if client.name == 'tsserver' then
    local actions = require('typescript').actions
    nnoremap(
      '<localleader>tr',
      '<cmd>TypescriptRenameFile<CR>',
      with_desc('typescript: rename file')
    )
    nnoremap('<localleader>tf', actions.fixAll, with_desc('typescript: fix all'))
    nnoremap('<localleader>tia', actions.addMissingImports, with_desc('typescript: add missing'))
    nnoremap('<localleader>tio', actions.organizeImports, with_desc('typescript: organize'))
    nnoremap('<localleader>tix', actions.removeUnused, with_desc('typescript: remove unused'))
  end
  -- Rust tools
  if client.name == 'rust_analyzer' then
    nnoremap(
      '<localleader>rh',
      '<cmd>RustToggleInlayHints<CR>',
      with_desc('rust-tools: toggle hints')
    )
    nnoremap('<localleader>rr', '<cmd>RustRunnables<CR>', with_desc('rust-tools: runnables'))
    nnoremap('<localleader>rt', '<cmd>lua _CARGO_TEST()<CR>', with_desc('rust-tools: cargo test'))
    nnoremap('<localleader>rm', '<cmd>RustExpandMacro<CR>', with_desc('rust-tools: expand cargo'))
    nnoremap('<localleader>rc', '<cmd>RustOpenCargo<CR>', with_desc('rust-tools: open cargo'))
    nnoremap('<localleader>rp', '<cmd>RustParentModule<CR>', with_desc('rust-tools: parent module'))
    nnoremap('<localleader>rd', '<cmd>RustDebuggables<CR>', with_desc('rust-tools: debuggables'))
    nnoremap(
      '<localleader>rv',
      '<cmd>RustViewCrateGraph<CR>',
      with_desc('rust-tools: view crate graph')
    )
    nnoremap(
      '<localleader>rR',
      "<cmd>lua require('rust-tools/workspace_refresh')._reload_workspace_from_cargo_toml()<CR>",
      with_desc('rust-tools: reload workspace')
    )
    nnoremap(
      '<localleader>ro',
      '<cmd>RustOpenExternalDocs<CR>',
      with_desc('rust-tools: open external docs')
    )
  end
end

----------------------------------------------------------------------------------------------------
-- LSP SETUP/TEARDOWN
----------------------------------------------------------------------------------------------------

-- @param client table
---@param bufnr number
local function setup_plugins(client, bufnr)
  -- nvim-navic
  local navic_ok, navic = rvim.safe_require('nvim-navic')
  if navic_ok and client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
  -- lsp-inlayhints
  local hints_ok, hints = rvim.safe_require('lsp-inlayhints')
  if hints_ok and client.name ~= 'tsserver' then hints.on_attach(client, bufnr) end
  -- document-color
  local document_color_ok, document_color = rvim.safe_require('document-color', { silent = true })
  if document_color_ok then
    if client.server_capabilities.colorProvider then document_color.buf_attach(bufnr) end
  end
  -- twoslash-queries
  local twoslash_ok, twoslash = rvim.safe_require('twoslash-queries', { silent = true })
  if twoslash_ok and client.name == 'tsserver' then twoslash.attach(client, bufnr) end
end

-- Add buffer local mappings, autocommands etc for attaching servers
-- this runs for each client because they have different capabilities so each time one
-- attaches it might enable autocommands or mappings that the previous client did not support
---@param client table the lsp client
---@param bufnr number
local function on_attach(client, bufnr)
  setup_plugins(client, bufnr)
  setup_autocommands(client, bufnr)
  setup_mappings(client, bufnr)
  api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

--- A set of custom overrides for specific lsp clients
--- This is a way of adding functionality for specific lsps
--- without putting all this logic in the general on_attach function
local client_overrides = {
  sqls = function(client, bufnr) require('sqls').on_attach(client, bufnr) end,
}

rvim.augroup('LspSetupCommands', {
  {
    event = { 'LspAttach' },
    desc = 'setup the language server autocommands',
    command = function(args)
      local bufnr = args.buf
      -- if the buffer is invalid we should not try and attach to it
      if not api.nvim_buf_is_valid(bufnr) or not args.data then return end
      local client = lsp.get_client_by_id(args.data.client_id)
      on_attach(client, bufnr)
      if client_overrides[client.name] then client_overrides[client.name](client, bufnr) end
    end,
  },
  {
    event = { 'LspDetach' },
    desc = 'Clean up after detached LSP',
    command = function(args)
      local client_id = args.data.client_id
      if not vim.b.lsp_events or not client_id then return end
      for _, state in pairs(vim.b.lsp_events) do
        if #state.clients == 1 and state.clients[1] == client_id then
          api.nvim_clear_autocmds({ group = state.group_id, buffer = args.buf })
        end
        vim.tbl_filter(function(id) return id ~= client_id end, state.clients)
      end
    end,
  },
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
  if rvim.lsp.diagnostics.signs.active then
    rvim.lsp.diagnostics.signs.active = false
    sign({ highlight = 'DiagnosticSignError', icon = codicons.lsp.error })
    sign({ highlight = 'DiagnosticSignWarn', icon = codicons.lsp.warn })
    sign({ highlight = 'DiagnosticSignInfo', icon = codicons.lsp.info })
    sign({ highlight = 'DiagnosticSignHint', icon = codicons.lsp.hint })
    return
  end
  rvim.lsp.diagnostics.signs.active = true
  sign({ highlight = 'DiagnosticSignError', icon = '' })
  sign({ highlight = 'DiagnosticSignWarn', icon = '' })
  sign({ highlight = 'DiagnosticSignInfo', icon = '' })
  sign({ highlight = 'DiagnosticSignHint', icon = '' })
end
toggle_diagnostic_signs()
command('ToggleDiagnosticSigns', toggle_diagnostic_signs)

----------------------------------------------------------------------------------------------------
-- Diagnostic Configuration
----------------------------------------------------------------------------------------------------
local max_width = math.min(math.floor(vim.o.columns * 0.7), 100)
local max_height = math.min(math.floor(vim.o.lines * 0.3), 30)

diagnostic.config({
  signs = { active = rvim.lsp.diagnostics.signs.active, values = codicons.lsp },
  underline = rvim.lsp.diagnostics.underline,
  update_in_insert = rvim.lsp.diagnostics.update_in_insert,
  severity_sort = rvim.lsp.diagnostics.severity_sort,
  virtual_lines = false,
  virtual_text = false,
  float = vim.tbl_deep_extend('keep', {
    max_width = max_width,
    max_height = max_height,
    prefix = function(diag, i, _)
      local level = diagnostic.severity[diag.severity]
      local prefix = fmt('%d. %s ', i, codicons.lsp[level:lower()])
      return prefix, 'Diagnostic' .. level:gsub('^%l', string.upper)
    end,
  }, rvim.lsp.diagnostics.float),
})

local function toggle_virtual_text()
  local prev_config = vim.diagnostic.config()
  local new_config = vim.tbl_extend('force', prev_config, { virtual_text = false })
  if type(prev_config.virtual_text) == 'boolean' then
    new_config = vim.tbl_extend('force', prev_config, {
      virtual_text = {
        prefix = '',
        spacing = rvim.lsp.diagnostics.virtual_text_spacing,
        format = function(d)
          local level = diagnostic.severity[d.severity]
          return fmt('%s %s', codicons.lsp[level:lower()], d.message)
        end,
      },
    })
  end
  vim.diagnostic.config(new_config)
end
command('ToggleVirtualText', toggle_virtual_text)

-- Generate templates
local templates = rvim.lsp.templates_dir
if not rvim.is_directory(templates) or fn.filereadable(join_paths(templates, 'lua.lua')) ~= 1 then
  require('user.lsp.templates').generate_templates()
  vim.notify('Templates have been generated', 'info', { title = 'Lsp' })
end
