-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/plugin/lsp.lua
if not rvim then return end

local lsp = vim.lsp
local fn = vim.fn
local api = vim.api
local fmt = string.format
local L = lsp.log_levels

local s = rvim.style
local codicons = s.codicons
local border = rvim.style.border.current
local diagnostic = vim.diagnostic

if vim.env.DEVELOPING then lsp.set_log_level(L.DEBUG) end

----------------------------------------------------------------------------------------------------
-- Autocommands
----------------------------------------------------------------------------------------------------
local FEATURES = {
  FORMATTING = 'formatting',
  CODELENS = 'codelens',
  DIAGNOSTICS = 'diagnostics',
  REFERENCES = 'references',
}

local get_augroup = function(bufnr, method)
  assert(bufnr, 'A bufnr is required to create an lsp augroup')
  return fmt('LspCommands_%d_%s', bufnr, method)
end

-- Show the popup diagnostics window, but only once for the current cursor location
-- by checking whether the word under the cursor has changed.
local function diagnostic_popup()
  local cword = vim.fn.expand('<cword>')
  if cword ~= vim.w.lsp_diagnostics_cword then
    vim.w.lsp_diagnostics_cword = cword
    vim.diagnostic.open_float(0, { scope = 'cursor', focus = false })
  end
end

local function formatting_filter(client)
  local exceptions = (rvim.lsp.format_exclusions)[vim.bo.filetype]
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

--- TODO: neovim upstream should validate the buffer itself rather than each user having to implement this logic
--- Check that a buffer is valid and loaded before calling a callback
--- it also ensures that a client which supports the capability is attached
---@param buf integer
---@return boolean, table[]
local function check_valid_client(buf, capability)
  if not is_buffer_valid(buf) then return false, {} end
  local clients = clients_by_capability(buf, capability)
  return next(clients) ~= nil, clients
end

--- Add lsp autocommands
---@param client table<string, any>
---@param bufnr number
local function setup_autocommands(client, bufnr)
  if not client then
    local msg = fmt('Unable to setup LSP autocommands, client for %d is missing', bufnr)
    return vim.notify(msg, 'error', { title = 'LSP Setup' })
  end

  if client.server_capabilities.documentFormattingProvider then
    if not rvim.find_string(rvim.lsp.format_on_save_exclusions, vim.bo.ft) then
      rvim.augroup(get_augroup(bufnr, FEATURES.FORMATTING), {
        {
          event = 'BufWritePre',
          buffer = bufnr,
          desc = 'LSP: Format on save',
          command = function(args)
            if
              not vim.g.formatting_disabled
              and not vim.b.formatting_disabled
              and not rvim.lang.format_on_save
            then
              format({ bufnr = args.buf, async = true })
              local multiple_formatters = #vim.tbl_filter(
                function(c) return c.server_capabilities.documentFormattingProvider end,
                lsp.get_active_clients({ buffer = bufnr })
              ) > 1
              format({ bufnr = args.buf, async = not multiple_formatters })
            end
          end,
        },
      })
    end
  end
  if client.server_capabilities.codeLensProvider then
    if rvim.lsp.code_lens_refresh then
      rvim.augroup(get_augroup(bufnr, FEATURES.CODELENS), {
        {
          event = { 'BufEnter', 'CursorHold', 'InsertLeave' },
          desc = 'LSP: Code Lens',
          buffer = bufnr,
          command = function(args)
            if check_valid_client(args.buf, 'codeLensProvider') then lsp.codelens.refresh() end
          end,
        },
      })
    end
  end
  if client.server_capabilities.documentHighlightProvider then
    if rvim.lsp.hover_diagnostics then
      rvim.augroup(get_augroup(bufnr, FEATURES.DIAGNOSTICS), {
        {
          event = { 'CursorHold' },
          buffer = bufnr,
          desc = 'LSP: Show diagnostics',
          command = function() diagnostic_popup() end,
        },
      })
    end
    if rvim.lsp.document_highlight then
      rvim.augroup(get_augroup(bufnr, FEATURES.REFERENCES), {
        {
          event = { 'CursorHold', 'CursorHoldI' },
          buffer = bufnr,
          desc = 'LSP: References',
          command = function(args)
            if check_valid_client(args.buf, 'documentHighlightProvider') then
              lsp.buf.document_highlight()
            end
          end,
        },
        {
          event = 'CursorMoved',
          desc = 'LSP: References Clear',
          buffer = bufnr,
          command = function(args)
            if check_valid_client(args.buf, 'documentHighlightProvider') then
              lsp.buf.clear_references()
            end
          end,
        },
      })
    end
  end
end

----------------------------------------------------------------------------------------------------
-- Mappings
----------------------------------------------------------------------------------------------------
local function setup_mappings(client, bufnr)
  local function with_desc(desc) return { buffer = bufnr, desc = desc } end
  if not client == nil then return end
  local nnoremap = rvim.nnoremap
  nnoremap('gl', function()
    local config = rvim.lsp.diagnostics.float
    config.scope = 'line'
    return vim.diagnostic.open_float({ scope = 'line' }, config)
  end, with_desc('lsp: line diagnostics'))
  nnoremap('K', lsp.buf.hover, with_desc('lsp: hover'))
  nnoremap('gd', lsp.buf.definition, with_desc('lsp: definition'))
  nnoremap('gr', lsp.buf.references, with_desc('lsp: references'))
  nnoremap('gD', lsp.buf.declaration, with_desc('lsp: go to declaration'))
  nnoremap('gi', lsp.buf.implementation, with_desc('lsp: go to implementation'))
  nnoremap('gt', lsp.buf.type_definition, with_desc('lsp: go to type definition'))
  nnoremap('gI', lsp.buf.incoming_calls, with_desc('lsp: incoming calls'))
  -- leader keymaps
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
  nnoremap('<leader>lf', '<cmd>LspFormat<cr>', with_desc('lsp: format buffer'))
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
end

----------------------------------------------------------------------------------------------------
-- LSP SETUP/TEARDOWN
----------------------------------------------------------------------------------------------------

-- @param client table
---@param bufnr number
-- TODO: Check if plugins are installed first
local function setup_plugins(client, bufnr)
  -- nvim-navic
  local navic_ok, navic = pcall(require, 'nvim-navic')
  if navic_ok and client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
  -- lsp-inlayhints
  local hints_ok, hints = pcall(require, 'lsp-inlayhints')
  if hints_ok then hints.on_attach(client, bufnr) end
  -- document-color
  local color_ok, color = pcall(require, 'document-color')
  if color_ok and client.server_capabilities.colorProvider then color.buf_attach(bufnr) end
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
      if not api.nvim_buf_is_valid(args.buf) or not args.data then return end
      local client = lsp.get_client_by_id(args.data.client_id)
      on_attach(client, bufnr)
      if client_overrides[client.name] then client_overrides[client.name](client, bufnr) end
    end,
  },
  {
    event = { 'LspDetach' },
    desc = 'Clean up after detached LSP',
    command = function(args)
      -- Only clear autocommands if there are no other clients attached to the buffer
      if next(lsp.get_active_clients({ bufnr = args.buf })) then return end
      rvim.foreach(
        function(feature)
          rvim.wrap_err(
            fmt('failed to clear buffer %d augroup for %s', args.buf, feature),
            api.nvim_clear_autocmds,
            { group = get_augroup(args.buf, feature), buffer = args.buf }
          )
        end,
        FEATURES
      )
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
local function make_diagnostic_qf_updater()
  local cmd_id = nil
  return function()
    if not api.nvim_buf_is_valid(0) then return end
    rvim.wrap_err(vim.diagnostic.setqflist, { open = false })
    rvim.toggle_list('quickfix')
    if not rvim.is_vim_list_open() and cmd_id then
      api.nvim_del_autocmd(cmd_id)
      cmd_id = nil
    end
    if cmd_id then return end
    cmd_id = api.nvim_create_autocmd('DiagnosticChanged', {
      callback = function()
        if rvim.is_vim_list_open() then
          rvim.wrap_err(vim.diagnostic.setqflist, { open = false })
          if #fn.getqflist() == 0 then rvim.toggle_list('quickfix') end
        end
      end,
    })
  end
end

command('LspDiagnostics', make_diagnostic_qf_updater())
rvim.nnoremap('<leader>ll', '<Cmd>LspDiagnostics<CR>', 'lsp: toggle quickfix diagnostics')

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
sign({ highlight = 'DiagnosticSignError', icon = codicons.lsp.error })
sign({ highlight = 'DiagnosticSignWarn', icon = codicons.lsp.warn })
sign({ highlight = 'DiagnosticSignInfo', icon = codicons.lsp.info })
sign({ highlight = 'DiagnosticSignHint', icon = codicons.lsp.hint })
----------------------------------------------------------------------------------------------------
-- Handler Overrides
----------------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------------
-- Diagnostic Configuration
----------------------------------------------------------------------------------------------------
local max_width = math.min(math.floor(vim.o.columns * 0.7), 100)
local max_height = math.min(math.floor(vim.o.lines * 0.3), 30)

local diagnostics = rvim.lsp.diagnostics
local float = rvim.lsp.diagnostics.float
local virtual_text = {
  prefix = '',
  spacing = diagnostics.virtual_text_spacing,
  format = function(d)
    local level = diagnostic.severity[d.severity]
    return fmt('%s %s', codicons.lsp[level:lower()], d.message)
  end,
}

diagnostic.config({
  signs = { active = diagnostics.signs.active, values = codicons.lsp },
  underline = diagnostics.underline,
  update_in_insert = diagnostics.update_in_insert,
  severity_sort = diagnostics.severity_sort,
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
  }, float),
})

-- NOTE: virtual_text should be set to false by default. see above
local function toggle_vt()
  local new_value = vim.diagnostic.config().virtual_text
  if type(new_value) == 'boolean' then
    vim.diagnostic.config({ virtual_text = virtual_text })
    return
  end
  vim.diagnostic.config({ virtual_text = false })
end
command('ToggleVirtualText', toggle_vt)
rvim.nnoremap('<leader>ov', toggle_vt, 'lsp: toggle virtual_text')

-- NOTE: the hover handler returns the bufnr,winnr so can be used for mappings
lsp.handlers['textDocument/hover'] =
  lsp.with(lsp.handlers.hover, { border = border, max_width = max_width, max_height = max_height })

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
local is_directory = require('user.utils').is_directory
local templates = rvim.lsp.templates_dir
if not is_directory(templates) or fn.filereadable(join_paths(templates, 'lua.lua')) ~= 1 then
  require('user.lsp.templates').generate_templates()
end
