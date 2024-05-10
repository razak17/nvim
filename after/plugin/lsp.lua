if not rvim or rvim.none then return end

local cwd = vim.fn.getcwd()

local disabled = not rvim.lsp.enable
  or not rvim.plugins.enable
  or rvim.plugins.minimal
  or (cwd and rvim.dirs_match(rvim.lsp.disabled.directories, cwd))

if disabled then return end

local lsp, fn, api, fmt = vim.lsp, vim.fn, vim.api, string.format
-- local L = vim.lsp.log_levels
local L, S = vim.lsp.log_levels, vim.diagnostic.severity
local M = vim.lsp.protocol.Methods
local conform = rvim.is_available('conform.nvim')

local diagnostic = vim.diagnostic
local augroup, icons, lsp_icons, border =
  rvim.augroup, rvim.ui.icons, rvim.ui.codicons.lsp, rvim.ui.current.border

local format_exclusions = {
  format_on_save = { 'zsh' },
  servers = {
    lua = { 'lua_ls' },
    go = { 'null-ls' },
    proto = { 'null-ls' },
    html = { 'html' },
    javascript = { 'quick_lint_js', 'tsserver', 'typescript-tools' },
    json = { 'jsonls' },
    typescript = { 'tsserver', 'typescript-tools' },
    typescriptreact = { 'tsserver', 'typescript-tools' },
    javascriptreact = { 'tsserver', 'typescript-tools' },
    svelte = { 'svelte' },
  },
}

if vim.env.DEVELOPING then lsp.set_log_level(L.DEBUG) end

--------------------------------------------------------------------------------
-- Autocommands
--------------------------------------------------------------------------------
local function formatting_filter(client)
  local exceptions = (format_exclusions.servers)[vim.bo.filetype]
  if not exceptions then return true end
  return not vim.tbl_contains(exceptions, client.name)
end

---@param opts {bufnr: integer, async: boolean, filter: fun(lsp.Client): boolean}
local function format(opts)
  opts = opts or {}
  if conform then
    local client_names = vim.tbl_map(
      function(client) return client.name end,
      vim.lsp.get_clients({ bufnr = opts.bufnr })
    )
    local lsp_fallback
    local lsp_fallback_inclusions = { 'eslint' }
    for _, c in pairs(client_names) do
      if rvim.find_string(lsp_fallback_inclusions, c) then
        lsp_fallback = 'always'
        break
      end
    end
    require('conform').format({
      bufnr = opts.bufnr,
      async = true,
      timeout_ms = 500,
      lsp_fallback = lsp_fallback or true,
    })
    return
  end
  lsp.buf.format({
    bufnr = opts.bufnr,
    async = opts.async,
    filter = formatting_filter,
  })
end

--------------------------------------------------------------------------------
--  Related Locations
--------------------------------------------------------------------------------
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

local publish_handler = lsp.handlers['textDocument/publishDiagnostics']
lsp.handlers['textDocument/publishDiagnostics'] = function(
  err,
  result,
  ctx,
  config
)
  result.diagnostics = vim.tbl_map(show_related_locations, result.diagnostics)
  publish_handler(err, result, ctx, config)
end

--------------------------------------------------------------------------------
--  Smart Definitions
--------------------------------------------------------------------------------
-- jump to the first definition automatically if the multiple defs are on the same line
-- otherwise show a telescope selector
-- from https://github.com/seblj/dotfiles/blob/014fd736413945c888d7258b298a37c93d5e97da/nvim/lua/config/lspconfig/handlers.lua

-- jump to the first definition automatically if the multiple defs are on the same line
-- otherwise show a telescope selector or qf list
---@param result table # A list of Location
---@param client vim.lsp.Client
local function jump_to_first_definition(result, client)
  if #result == 1 then
    lsp.util.jump_to_location(result[1], client.offset_encoding)
    return
  end

  if not rvim.is_available('telescope.nvim') then
    -- show in qf if telescope is not available
    fn.setqflist({}, ' ', {
      title = 'LSP locations',
      items = lsp.util.locations_to_items(result, client.offset_encoding),
    })
    api.nvim_command('botright copen')
    return
  end

  local results = lsp.util.locations_to_items(result, client.offset_encoding)
  local lnum, filename = results[1].lnum, results[1].filename

  for _, val in pairs(results) do
    if val.lnum ~= lnum or val.filename ~= filename then
      return require('telescope.builtin').lsp_definitions()
    end
  end
end

lsp.handlers['textDocument/definition'] = function(_, result, ctx, _)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client then
    if result == nil or vim.tbl_isempty(result) then
      local _ = lsp.log.info() and lsp.log.info(ctx.method, 'No location found')
      return nil
    end

    if vim.islist(result) then
      jump_to_first_definition(result, client)
    else
      lsp.util.jump_to_location(result, client.offset_encoding)
    end
  end
end

lsp.handlers['textDocument/references'] = function(_, _, _)
  require('telescope.builtin').lsp_references()
end

--------------------------------------------------------------------------------
--  Truncate typescript inlay hints
--------------------------------------------------------------------------------
-- Workaround for truncating long TypeScript inlay hints.
-- TODO: Remove this if https://github.com/neovim/neovim/issues/27240 gets addressed.
-- local inlay_hint_handler = lsp.handlers[M.textDocument_inlayHint]
-- lsp.handlers[M.textDocument_inlayHint] = function(err, result, ctx, config)
--   local client = lsp.get_client_by_id(ctx.client_id)
--   if not client then return end
--   if client.name == 'typescript-tools' or client.name == 'tsserver' then
--     result = vim
--       .iter(result)
--       :map(function(hint)
--         local label = hint.label ---@type string
--         if label:len() >= 30 then
--           label = label:sub(1, 29) .. icons.misc.ellipsis
--         end
--         hint.label = label
--         return hint
--       end)
--       :totable()
--   end
--   inlay_hint_handler(err, result, ctx, config)
-- end

--------------------------------------------------------------------------------
-- Mappings
--------------------------------------------------------------------------------
---Setup mapping when an lsp attaches to a buffer
---@param client vim.lsp.Client
---@param bufnr integer
local function setup_mappings(client, bufnr)
  local function prev_diagnostic()
    return function()
      diagnostic.goto_prev({
        float = rvim.lsp.hover_diagnostics.go_to
          and not rvim.lsp.hover_diagnostics.enable,
        ---@diagnostic disable-next-line: assign-type-mismatch
        severity = {
          min = vim.diagnostic.severity.HINT,
        },
      })
    end
  end
  local function next_diagnostic()
    return function()
      diagnostic.goto_next({
        float = rvim.lsp.hover_diagnostics.go_to
          and not rvim.lsp.hover_diagnostics.enable,
        ---@diagnostic disable-next-line: assign-type-mismatch
        severity = {
          min = vim.diagnostic.severity.HINT,
        },
      })
    end
  end
  local function line_diagnostic()
    return function()
      local config = diagnostic.config().float
      if type(config) == 'table' then
        return vim.diagnostic.open_float(vim.tbl_extend('force', config, {
          focusable = true,
          scope = 'line',
        }))
      end
    end
  end

  local mappings = {
    { 'n', '<leader>lk', prev_diagnostic(), desc = 'go to prev diagnostic' },
    { 'n', '<leader>lj', next_diagnostic(), desc = 'go to next diagnostic' },
    {
      'n',
      '<leader>lh',
      function()
        local enabled = lsp.inlay_hint.is_enabled(0)
        lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
      end,
      desc = 'toggle inlay hints',
      M.textDocument_inlayHint,
    },
    {
      { 'n', 'x' },
      '<leader>la',
      -- lsp.buf.code_action,
      function()
        vim.lsp.buf.code_action({
          context = {
            diagnostics = rvim.lsp.get_diagnostic_at_cursor(),
          },
        })
      end,
      desc = 'code action',
      capability = M.textDocument_codeAction,
    },
    {
      'n',
      '<leader>lf',
      format,
      desc = 'format buffer',
      capability = not conform and M.textDocument_formatting or nil,
    },
    {
      'n',
      'gd',
      lsp.buf.definition,
      desc = 'definition',
      capability = M.textDocument_definition,
      exclude = { 'tsserver' },
    },
    {
      'n',
      'gl',
      line_diagnostic(),
      desc = 'line diagnostics',
      capability = M.textDocument_hover,
    },
    {
      'n',
      'gr',
      lsp.buf.references,
      desc = 'references',
      capability = M.textDocument_references,
    },
    {
      'n',
      'gi',
      lsp.buf.implementation,
      desc = 'implementation',
      capability = M.textDocument_references,
    },
    {
      'n',
      'gI',
      lsp.buf.incoming_calls,
      desc = 'incoming calls',
      capability = M.textDocument_references,
      disabled = rvim.is_available('lspsaga.nvim'),
    },
    {
      'n',
      'gt',
      lsp.buf.type_definition,
      desc = 'go to type definition',
      capability = M.textDocument_definition,
    },
    {
      'n',
      '<leader>lc',
      lsp.codelens.run,
      desc = 'run code lens',
      capability = M.textDocument_codeLens,
    },
    {
      'n',
      '<leader>lr',
      lsp.buf.rename,
      desc = 'rename',
      capability = M.textDocument_rename,
    },
    {
      'n',
      '<leader>ll',
      vim.diagnostic.setloclist,
      desc = 'toggle loclist diagnostics',
    },
    { 'n', '<leader>li', '<Cmd>LspInfo<CR>', desc = 'lsp info' },
    {
      'n',
      '<localleader>lc',
      '<Cmd>lua =vim.lsp.get_clients()[1].server_capabilities<CR>',
      desc = 'server capabilities',
      disabled = rvim.is_available('lspsaga.nvim'),
    },
  }

  vim.iter(mappings):each(function(m)
    if
      (not m.exclude or not vim.tbl_contains(m.exclude, vim.bo[bufnr].ft))
      and (not m.exclude_ft or not vim.tbl_contains(
        m.exclude_ft,
        vim.bo[bufnr].ft
      ))
      and (not m.capability or client.supports_method(m.capability))
      and not m.disabled
    then
      map(m[1], m[2], m[3], { buffer = bufnr, desc = fmt('lsp: %s', m.desc) })
    end
  end)
end

--------------------------------------------------------------------------------
-- LSP SETUP/TEARDOWN
--------------------------------------------------------------------------------

---@alias ClientOverrides {on_attach: fun(client: vim.lsp.Client, bufnr: number), semantic_tokens: fun(bufnr: number, client: vim.lsp.Client, token: table)}

--- A set of custom overrides for specific lsp clients
--- This is a way of adding functionality for specific lsps
--- without putting all this logic in the general on_attach function
---@type {[string]: ClientOverrides}
local client_overrides = {
  tsserver = {
    semantic_tokens = function(bufnr, client, token)
      if
        token.type == 'variable'
        and token.modifiers['local']
        and not token.modifiers.readonly
      then
        lsp.semantic_tokens.highlight_token(token, bufnr, client.id, '@danger')
      end
    end,
    on_attach = function(client)
      -- this is important, otherwise tsserver will format ts/js
      -- files which we *really* don't want.
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end,
  },
  ruff_lsp = {
    on_attach = function(client)
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end,
  },
}

---@param client vim.lsp.Client
---@param bufnr number
local function setup_semantic_tokens(client, bufnr)
  local overrides = client_overrides[client.name]
  if not overrides or not overrides.semantic_tokens then return end
  augroup(fmt('LspSemanticTokens%s', client.name), {
    event = 'LspTokenUpdate',
    buffer = bufnr,
    desc = fmt('Configure the semantic tokens for the %s', client.name),
    command = function(args)
      overrides.semantic_tokens(args.buf, client, args.data.token)
    end,
  })
end

---@param client vim.lsp.Client
---@param buf integer
local function setup_autocommands(client, buf)
  if client.supports_method(M.textDocument_hover) then
    augroup(('LspHoverDiagnostics%d'):format(buf), {
      event = { 'CursorHold' },
      buffer = buf,
      desc = 'LSP: Show diagnostics',
      command = function()
        if
          not rvim.lsp.hover_diagnostics.enable or not rvim.lsp.timeout.enable
        then
          return
        end
        if
          vim.b.lsp_hover_win and api.nvim_win_is_valid(vim.b.lsp_hover_win)
        then
          return
        end
        vim.diagnostic.open_float({ scope = rvim.lsp.hover_diagnostics.scope })
      end,
    })
  end

  if client.supports_method('textDocument/inlayHint', { bufnr = buf }) then
    lsp.inlay_hint.enable(false, { bufnr = 0 })
  end

  if client.supports_method(M.textDocument_formatting) then
    augroup(('LspFormatting%d'):format(buf), {
      event = 'BufWritePre',
      buffer = buf,
      desc = 'LSP: Format on save',
      command = function(args)
        if
          not vim.g.formatting_disabled
          and not vim.b[buf].formatting_disabled
          and rvim.lsp.format_on_save.enable
        then
          local clients = vim.tbl_filter(
            function(c) return c.supports_method(M.textDocument_formatting) end,
            lsp.get_clients({ buffer = buf })
          )
          if #clients >= 1 then
            format({ bufnr = args.buf, async = #clients == 1 })
          end
        end
      end,
    })
  end

  if client.supports_method(M.textDocument_codeLens) then
    augroup(('LspCodeLens%d'):format(buf), {
      event = { 'BufEnter', 'InsertLeave', 'BufWritePost' },
      desc = 'LSP: Code Lens',
      buffer = buf,
      -- call via vimscript so that errors are silenced
      -- command = 'silent! lua vim.lsp.codelens.refresh()',
      command = function(args)
        if not args or not args.data then return end
        if client.supports_method(M.textDocument_codeLens) then
          lsp.codelens.refresh({
            bufnr = args.buf,
            client_id = client.id,
          })
        end
      end,
    })
  end

  if client.supports_method(M.textDocument_documentHighlight) then
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
---@param client vim.lsp.Client the lsp client
---@param bufnr number
local function on_attach(client, bufnr)
  setup_autocommands(client, bufnr)
  setup_mappings(client, bufnr)
  if rvim.lsp.semantic_tokens.enable then
    setup_semantic_tokens(client, bufnr)
  end
end

augroup('LspSetupAutoCommands', {
  event = { 'LspAttach' },
  desc = 'setup the language server autocommands',
  command = function(args)
    local client = lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    on_attach(client, args.buf)
    local overrides = client_overrides[client.name]
    if not overrides or not overrides.on_attach then return end
    overrides.on_attach(client, args.buf)
    api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', {
      buf = args.buf,
    })
  end,
}, {
  event = 'DiagnosticChanged',
  desc = 'Update the diagnostic locations',
  command = function(args)
    if not rvim.lsp.omnifunc.enable then
      diagnostic.setloclist({ open = false })
    end
    if #args.data.diagnostics == 0 then vim.cmd('silent! lclose') end
  end,
})
--------------------------------------------------------------------------------
-- Handler Overrides
--------------------------------------------------------------------------------
-- This section overrides the default diagnostic handlers for signs and virtual text so that only
-- the most severe diagnostic is shown per line

--- The custom namespace is so that ALL diagnostics across all namespaces can be aggregated
--- including diagnostics from plugins
local ns = api.nvim_create_namespace('severe-diagnostics')

--- Restricts nvim's diagnostic signs to only the single most severe one per line
--- see `:help vim.diagnostic`
---@param callback fun(namespace: integer, bufnr: integer, diagnostics: table, opts: table)
---@return fun(namespace: integer, bufnr: integer, diagnostics: table, opts: table)
local function max_diagnostic(callback)
  return function(_, bufnr, diagnostics, opts)
    local max_severity_per_line = vim
      .iter(diagnostics)
      :fold({}, function(diag_map, d)
        local m = diag_map[d.lnum]
        if not m or d.severity < m.severity then diag_map[d.lnum] = d end
        return diag_map
      end)
    callback(ns, bufnr, vim.tbl_values(max_severity_per_line), opts)
  end
end

local signs_handler = diagnostic.handlers.signs
diagnostic.handlers.signs = vim.tbl_extend('force', signs_handler, {
  show = max_diagnostic(signs_handler.show),
  hide = function(_, bufnr) signs_handler.hide(ns, bufnr) end,
})
--------------------------------------------------------------------------------
-- Diagnostic Configuration
--------------------------------------------------------------------------------
local max_width = math.min(math.floor(vim.o.columns * 0.7), 100)
local max_height = math.min(math.floor(vim.o.lines * 0.3), 30)

--------------------------------------------------------------------------------
-- Signs
--------------------------------------------------------------------------------
---@param kind? string
local function get_signs(kind)
  return {
    [S.WARN] = kind and fmt('DiagnosticSignWarn%s', kind) or lsp_icons.warn,
    [S.INFO] = kind and fmt('DiagnosticSignInfo%s', kind) or lsp_icons.info,
    [S.HINT] = kind and fmt('DiagnosticSignHint%s', kind) or lsp_icons.hint,
    [S.ERROR] = kind and fmt('DiagnosticSignError%s', kind) or lsp_icons.error,
  }
end

function rvim.get_lsp_signs()
  return {
    text = get_signs(),
    texthl = get_signs(''),
    numhl = get_signs('Nr'),
    culhl = get_signs('CursorNr'),
    linehl = get_signs('Line'),
  }
end

diagnostic.config({
  signs = rvim.lsp.signs.enable and rvim.get_lsp_signs() or false,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_lines = false,
  virtual_text = false,
  float = {
    max_width = max_width,
    max_height = max_height,
    border = border,
    title = {
      { '  ', 'DiagnosticFloatTitleIcon' },
      { 'Problems  ', 'DiagnosticFloatTitle' },
    },
    focusable = false,
    scope = 'cursor',
    source = true,
    prefix = function(diag)
      local level = diagnostic.severity[diag.severity]
      local prefix = fmt('%s ', lsp_icons[level:lower()])
      return prefix, 'Diagnostic' .. level:gsub('^%l', string.upper)
    end,
  },
})
--------------------------------------------------------------------------------
-- LSP Progress
--------------------------------------------------------------------------------
if rvim.lsp.progress.enable then require('rm.lsp_progress') end
--------------------------------------------------------------------------------
-- Code Action
--------------------------------------------------------------------------------
-- ref: https://github.com/rockyzhang24/dotfiles/blob/master/.config/nvim/lua/rockyz/lsp/lightbulb.lua

--- Get diagnostics (LSP Diagnostic) at the cursor
---
--- Grab the code from https://github.com/neovim/neovim/issues/21985
---
--- TODO:
--- This PR (https://github.com/neovim/neovim/pull/22883) extends
--- vim.diagnostic.get to return diagnostics at cursor directly and even with
--- LSP Diagnostic structure. If it gets merged, simplify this funciton (the
--- code for filter and build can be removed).
---
---@return table # A table of LSP Diagnostic
function rvim.lsp.get_diagnostic_at_cursor()
  local cur_bufnr = api.nvim_get_current_buf()
  local line, col = unpack(api.nvim_win_get_cursor(0)) -- line is 1-based indexing
  -- Get a table of diagnostics at the current line. The structure of the
  -- diagnostic item is defined by nvim (see :h diagnostic-structure) to
  -- describe the information of a diagnostic.
  local diagnostics = diagnostic.get(cur_bufnr, { lnum = line - 1 }) -- lnum is 0-based indexing
  -- Filter out the diagnostics at the cursor position. And then use each to
  -- build a LSP Diagnostic (see
  -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#diagnostic)
  local lsp_diagnostics = {}
  for _, diag in pairs(diagnostics) do
    if diag.col <= col and diag.end_col >= col then
      table.insert(lsp_diagnostics, {
        range = {
          ['start'] = {
            line = diag.lnum,
            character = diag.col,
          },
          ['end'] = {
            line = diag.end_lnum,
            character = diag.end_col,
          },
        },
        severity = diag.severity,
        code = diag.code,
        source = diag.source or nil,
        message = diag.message,
      })
    end
  end
  return lsp_diagnostics
end
