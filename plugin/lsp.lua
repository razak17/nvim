if not ar or ar.none then return end

local cwd = vim.fn.getcwd()

local disabled = not ar.lsp.enable
  or not ar.plugins.enable
  or (cwd and ar.dirs_match(ar_config.lsp.disabled.directories, cwd))

if disabled then return end

local lsp, fn, api, fmt = vim.lsp, vim.fn, vim.api, string.format
local L, S = lsp.log_levels, vim.diagnostic.severity
local M = vim.lsp.protocol.Methods
local is_available = ar.is_available
local conform = is_available('conform.nvim')

local diagnostic = vim.diagnostic
local format = require('ar.lsp_format')
local utils = require('ar.utils.lsp')
local lsp_diag = require('ar.lsp_diagnostics')
local augroup, diag_icons, border =
  ar.augroup, ar.ui.codicons.lsp, ar.ui.current.border

if vim.env.DEVELOPING then lsp.log.set_level(L.DEBUG) end

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
      not ar.falsy(info.message) and (': %s'):format(info.message) or ''
    )
  end
  return diag
end

local publish_handler = lsp.handlers[M.textDocument_publishDiagnostics]
lsp.handlers[M.textDocument_publishDiagnostics] = function(err, result, ctx)
  result.diagnostics = vim.tbl_map(show_related_locations, result.diagnostics)
  local client = lsp.get_client_by_id(ctx.client_id)
  local ts_servers = { 'tsgo', 'ts_ls', 'vtsls' }
  if client and (vim.tbl_contains(ts_servers, client.name)) then
    lsp_diag.on_publish_diagnostics(err, result, ctx)
  end
  publish_handler(err, result, ctx)
end
--------------------------------------------------------------------------------
--  Smart Definitions
--------------------------------------------------------------------------------
-- from https://github.com/seblj/dotfiles/blob/014fd736413945c888d7258b298a37c93d5e97da/nvim/lua/config/lspconfig/handlers.lua

-- jump to the first definition automatically if the multiple defs are on the same line
-- otherwise show a selector based on ar_config.picker or qf list
---@param result table # A list of Location
---@param client vim.lsp.Client
local function jump_to_first_definition(result, client)
  local results = lsp.util.locations_to_items(result, client.offset_encoding)
  if
    #results == 1 or (#results == 2 and results[1].lnum == results[2].lnum)
  then
    return lsp.util.show_document(result[1], client.offset_encoding)
  end

  local bufnr = api.nvim_get_current_buf()
  local path = api.nvim_buf_get_name(bufnr)

  -- goto definition of local variable if it is in the same file
  for i, val in pairs(results) do
    if path == val.filename then
      return lsp.util.show_document(result[i], client.offset_encoding)
    end
  end

  if not ar.pick.picker then
    -- show in qf if picker is not available
    fn.setqflist({}, ' ', {
      title = 'LSP locations',
      items = lsp.util.locations_to_items(result, client.offset_encoding),
    })
    vim.cmd('botright copen')
    return
  end

  local lnum, filename = results[1].lnum, results[1].filename

  for _, val in pairs(results) do
    if val.lnum ~= lnum or val.filename ~= filename then
      return ar.pick('lsp_definitions')()
    end
  end
end

---@param client vim.lsp.Client
---@param result table
---@param method string
local function goto_definition_handler(client, result, method)
  if not result or vim.tbl_isempty(result) then
    local _ = lsp.log.info() and lsp.log.info(method, 'No location found')
    return
  end

  if vim.islist(result) then
    jump_to_first_definition(result, client)
  else
    if type(result) == 'table' and client.name == 'lua_ls' then
      result = { result[1] }
    end
    lsp.util.show_document(result, client.offset_encoding)
  end
  vim.cmd([[norm! zz]])
end

local definition = lsp.buf.definition
---@diagnostic disable-next-line: duplicate-set-field
lsp.buf.definition = function()
  return definition({
    on_list = function(options)
      local method = options.context.method
      local clients = lsp.get_clients({
        method = method,
        bufnr = options.context.bufnr,
      })
      if not next(clients) then
        vim.notify(lsp._unsupported_method(method), L.WARN)
        return
      end
      local win = api.nvim_get_current_win()
      for _, client in ipairs(clients) do
        local params =
          lsp.util.make_position_params(win, client.offset_encoding)
        client:request(
          method,
          params,
          function(_, result) goto_definition_handler(client, result, method) end
        )
      end
    end,
  })
end

local function references_handler()
  local params = {}
  if
    vim.bo.filetype == 'typescript' or vim.bo.filetype == 'typescriptreact'
  then
    -- for typescript, filter out import statements
    local Path = require('plenary.path')
    params.post_process_results = function(list)
      return vim.tbl_filter(function(match)
        local file = match.uri:gsub('file://', '')
        local lnum = match.range.start.line
        if lnum + 1 == vim.fn.line('.') and file == vim.fn.expand('%:p') then
          -- drop the declaration i'm asking the references from...
          -- not sure why typescript is listing the declaration in the references...
          return false
        end
        local path = Path.new(file)
        local contents = path:read()
        local it = contents:gmatch('([^\n]*)\n?')
        local line = ''
        for _ = 0, lnum, 1 do
          line = it()
        end
        return not line:match('^%s*import ')
      end, list)
    end
  end

  ar.pick('lsp_references', params)()
end

local references = lsp.buf.references
---@diagnostic disable-next-line: duplicate-set-field
lsp.buf.references = function()
  return references(nil, {
    on_list = function(options)
      if not ar.pick.picker then
        fn.setqflist({}, ' ', options)
        vim.cmd('botright copen')
        return
      end
      references_handler()
    end,
  })
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
--   if client.name == 'typescript-tools' or client.name == 'ts_ls' or client.name == 'vtsls' then
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
  --- Diagnostic go_to
  ---@param next boolean
  ---@param severity string
  ---@return function
  local diagnostic_goto = function(next, severity)
    local go = diagnostic.jump
    severity = severity and vim.diagnostic.severity[severity] or nil
    local float = ar_config.lsp.hover_diagnostics.go_to
      and not ar_config.lsp.hover_diagnostics.enable
    return ar.demicolon_jump(function(opts)
      local count = opts.forward and 1 or -1
      count = count * vim.v.count1
      go({ count = count, severity = severity, float = float })
    end, { forward = next })
  end
  local function diagnostic_float(line)
    local config = diagnostic.config().float or {}
    config.scope = line and 'line' or 'cursor'
    ---@diagnostic disable-next-line: inject-field
    config.focusable = true
    return function() return vim.diagnostic.open_float(config) end
  end

  local mappings = {
    { 'n', '<leader>lk', diagnostic_goto(false), desc = 'prev diagnostic' },
    { 'n', '<leader>lj', diagnostic_goto(true), desc = 'next diagnostic' },
    { 'n', ']d', diagnostic_goto(true), desc = 'next diagnostic' },
    { 'n', '[d', diagnostic_goto(false), desc = 'prev diagnostic' },
    { 'n', ']e', diagnostic_goto(true, 'ERROR'), desc = 'next error' },
    { 'n', '[e', diagnostic_goto(false, 'ERROR'), desc = 'prev error' },
    { 'n', ']w', diagnostic_goto(true, 'WARN'), desc = 'next warning' },
    { 'n', '[w', diagnostic_goto(false, 'WARN'), desc = 'prev warning' },
    {
      'n',
      'gL',
      function()
        if not ar.plugin_available('lsplinks.nvim') then return end
        require('lsplinks').gx()
      end,
      desc = 'open lsp links',
      capability = M.documentLinkProvider,
    },
    {
      'n',
      '<leader>lh',
      function()
        local enabled = lsp.inlay_hint.is_enabled({ bufnr = bufnr })
        lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
      end,
      desc = 'toggle inlay hints',
      capability = M.textDocument_inlayHint,
    },
    {
      'n',
      '<leader>lt',
      function()
        local enabled = lsp.semantic_tokens.is_enabled({ bufnr = bufnr })
        lsp.semantic_tokens.enable(not enabled, { bufnr = bufnr })
      end,
      desc = 'toggle semantic tokens',
      capability = M.textDocument_semanticTokens_full,
    },
    {
      'n',
      '<leader>lK',
      function()
        local enabled = lsp.document_color.is_enabled(bufnr)
        lsp.document_color.enable(not enabled, bufnr)
      end,
      desc = 'toggle colors',
      capability = M.textDocument_documentColor,
    },
    {
      'n',
      '<leader>lY',
      function()
        local line = api.nvim_win_get_cursor(0)[1]
        local diagnostics = diagnostic.get(0, { lnum = line - 1 })
        -- empty the register first
        fn.setreg('+', {}, 'V')
        for _, d in ipairs(diagnostics) do
          fn.setreg('+', vim.fn.getreg('+') .. d['message'], 'V')
        end
        vim.notify(
          ('Yanked %d diagnostics to + register'):format(#diagnostics),
          L.INFO
        )
      end,
      desc = 'yank line diagnostics',
    },
    {
      { 'n', 'x' },
      '<leader>laa',
      -- lsp.buf.code_action,
      function()
        --   vim.lsp.buf.code_action({
        --     context = { diagnostics = lsp_diag.get_diagnostic_at_cursor() },
        --   })
        local win = api.nvim_get_current_win()
        ---@type lsp.CodeActionParams
        local params = lsp.util.make_range_params(win, client.offset_encoding)
        params.context = {
          triggerKind = lsp.protocol.CodeActionTriggerKind.Invoked,
          diagnostics = lsp_diag.get_diagnostic_at_cursor(),
        }
        require('ar.lsp_code_action').better_code_actions(bufnr, params)
      end,
      desc = 'code action',
      capability = M.textDocument_codeAction,
    },
    {
      { 'n', 'x' },
      '<leader>las',
      function()
        lsp.buf.code_action({
          apply = true,
          context = { only = { 'source' }, diagnostics = {} },
        })
      end,
      desc = 'source action',
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
    },
    { 'n', 'gl', diagnostic_float(), desc = 'cursor diagnostics' },
    { 'n', 'gL', diagnostic_float(true), desc = 'line diagnostics' },
    -- {
    --   'n',
    --   'gr',
    --   references_handler,
    --   desc = 'references',
    --   capability = M.textDocument_references,
    -- },
    -- {
    --   'n',
    --   'gi',
    --   lsp.buf.implementation,
    --   desc = 'implementation',
    --   capability = M.textDocument_references,
    -- },
    {
      'n',
      'gI',
      lsp.buf.incoming_calls,
      desc = 'incoming calls',
      capability = M.textDocument_references,
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
      '<leader>ln',
      lsp.buf.rename,
      desc = 'rename',
      capability = M.textDocument_rename,
      disabled = ar_config.lsp.rename.variant ~= 'builtin',
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
    },
    {
      'n',
      '<localleader>lwa',
      lsp.buf.add_workspace_folder,
      desc = 'add workspace folder',
    },
    {
      'n',
      '<localleader>lwr',
      lsp.buf.remove_workspace_folder,
      desc = 'remove workspace folder',
    },
    {
      'n',
      '<localleader>lwl',
      function() vim.print(vim.lsp.buf.list_workspace_folders()) end,
      desc = 'list workspace folders',
    },
  }

  vim.iter(mappings):each(function(m)
    if
      (not m.exclude or not vim.tbl_contains(m.exclude, vim.bo[bufnr].ft))
      and (not m.exclude_ft or not vim.tbl_contains(
        m.exclude_ft,
        vim.bo[bufnr].ft
      ))
      and (not m.capability or client:supports_method(m.capability))
      and not m.disabled
    then
      map(m[1], m[2], m[3], { buffer = bufnr, desc = fmt('lsp: %s', m.desc) })
    end
  end)
end

--------------------------------------------------------------------------------
-- LSP SETUP/TEARDOWN
--------------------------------------------------------------------------------
local ts_overrides = {
  semantic_tokens = function(bufnr, client, token)
    if
      token.type == 'variable'
      and token.modifiers['local']
      and not token.modifiers.readonly
    then
      lsp.semantic_tokens.highlight_token(token, bufnr, client.id, '@danger')
    end
  end,
  on_attach = function(client, bufnr)
    if is_available('twoslash-queries.nvim') then
      require('twoslash-queries').attach(client, bufnr)
    end
    -- this is important, otherwise ts_ls will format ts/js
    -- files which we *really* don't want.
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
}

---@alias ClientOverrides {on_attach: fun(client: vim.lsp.Client, bufnr: number), semantic_tokens: fun(bufnr: number, client: vim.lsp.Client, token: table)}

--- A set of custom overrides for specific lsp clients
--- This is a way of adding functionality for specific lsps
--- without putting all this logic in the general on_attach function
---@type {[string]: ClientOverrides}
local client_overrides = {
  graphql = {
    on_attach = function(client)
      -- Disable workspaceSymbolProvider because this prevents
      -- searching for symbols in typescript files which this server
      -- is also enabled for.
      -- @see: https://github.com/nvim-telescope/telescope.nvim/issues/964
      client.server_capabilities.workspaceSymbolProvider = false
    end,
  },
  ts_ls = ts_overrides,
  vtsls = ts_overrides,
  ['typescript-tools'] = ts_overrides,
  ruff = {
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
  if client:supports_method(M.textDocument_hover) then
    augroup(('LspHoverDiagnostics%d'):format(buf), {
      event = { 'CursorHold' },
      buffer = buf,
      desc = 'LSP: Show diagnostics',
      command = function()
        if not ar_config.lsp.hover_diagnostics.enable then return end
        if
          vim.b.lsp_hover_win and api.nvim_win_is_valid(vim.b.lsp_hover_win)
        then
          return
        end
        vim.diagnostic.open_float({
          scope = ar_config.lsp.hover_diagnostics.scope,
        })
      end,
    })
  end

  if client:supports_method(M.textDocument_inlayHint, { bufnr = buf }) then
    lsp.inlay_hint.enable(ar_config.lsp.inlay_hint.enable, { bufnr = buf })
  end

  if client:supports_method(M.textDocument_formatting) then
    augroup(('LspFormatting%d'):format(buf), {
      event = 'BufWritePre',
      buffer = buf,
      desc = 'LSP: Format on save',
      command = function(args)
        if
          not vim.g.formatting_disabled
          and not vim.b[buf].formatting_disabled
          and ar_config.lsp.format_on_save.enable
        then
          local clients = vim.tbl_filter(
            function(c) return c:supports_method(M.textDocument_formatting) end,
            lsp.get_clients({ buffer = buf })
          )
          if #clients >= 1 then
            format({ bufnr = args.buf, async = #clients == 1 })
          end
        end
      end,
    })
  end

  if client:supports_method(M.textDocument_codeLens) then
    augroup(('LspCodeLens%d'):format(buf), {
      event = { 'BufEnter', 'InsertLeave', 'BufWritePost' },
      desc = 'LSP: Code Lens',
      buffer = buf,
      -- call via vimscript so that errors are silenced
      -- command = 'silent! lua vim.lsp.codelens.refresh()',
      command = function(args)
        if not args or not args.data then return end
        if client:supports_method(M.textDocument_codeLens) then
          lsp.codelens.refresh({
            bufnr = args.buf,
            client_id = client.id,
          })
        end
      end,
    })
  end

  if client:supports_method(M.textDocument_documentHighlight) then
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

-- Ref: https://github.com/CRAG666/dotfiles/blob/main/config/nvim/lua/config/lsp/init.lua
local lsp_autostop_pending
---Automatically stop LSP servers that no longer attach to any buffers
---
---  Once `BufDelete` is triggered, wait for 60s before checking and
---  stopping servers, in this way the callback will be invoked once
---  every 60 seconds at most and can stop multiple clients at once
---  if possible, which is more efficient than checking and stopping
---  clients on every `BufDelete` events

local function setup_lsp_stop_detached()
  ar.augroup('LspAutoStop', {
    event = { 'BufDelete' },
    desc = 'Automatically stop detached language servers.',
    command = function()
      if lsp_autostop_pending then return end
      lsp_autostop_pending = true
      vim.defer_fn(function()
        lsp_autostop_pending = nil
        for _, client in ipairs(lsp.get_clients()) do
          if vim.tbl_isempty(client.attached_buffers) then
            utils.soft_stop(client)
          end
        end
      end, 60000)
    end,
  })
end

---@param client vim.lsp.Client
---@param bufnr number
local function setup_lsp_plugins(client, bufnr)
  if is_available('workspace-diagnostics.nvim') then
    require('workspace-diagnostics').populate_workspace_diagnostics(
      client,
      bufnr
    )
  end
  if is_available('hierarchy.nvim') then
    ar.command(
      'FuncReferences',
      function()
        require('hierarchy').find_recursive_calls(3, client.offset_encoding)
      end,
      {
        nargs = '?',
        desc = 'Find function references recursively. Usage: FunctionReferences [depth]',
      }
    )
  end
end

---@param client vim.lsp.Client
---@param bufnr number
local function setup_colors(client, bufnr)
  if
    client:supports_method(M.textDocument_documentColor)
    or client.capabilities.textDocument.colorProvider -- NOTE: this is needed for tailwind colors
  then
    lsp.document_color.enable(true, bufnr, { style = 'virtual' })
  end
end

---@param client vim.lsp.Client
local function setup_lsp_foldexpr(client)
  if client:supports_method(M.textDocument_foldingRange) then
    local win = api.nvim_get_current_win()
    vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
  end
end

---@param client vim.lsp.Client
---@param bufnr number
local function setup_completion(client, bufnr)
  if client:supports_method(M.textDocument_completion) then
    lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    -- api.nvim_set_option_value(
    --   'omnifunc',
    --   'v:lua.vim.lsp.omnifunc',
    --   { buf = bufnr }
    -- )
  end
end

---@param client vim.lsp.Client
---@param bufnr number
local function setup_inline_completion(client, bufnr)
  if client:supports_method(M.textDocument_inlineCompletion) then
    vim.opt.completeopt =
      { 'menuone', 'noselect', 'noinsert', 'fuzzy', 'popup' }
    lsp.inline_completion.enable(true)
    map('i', '<A-u>', function()
      if not lsp.inline_completion.get() then return '<A-u>' end
    end, {
      replace_keycodes = true,
      expr = true,
      desc = 'current inline completion',
    })
  end
end

-- Add buffer local mappings, autocommands etc for attaching servers
-- this runs for each client because they have different capabilities so each time one
-- attaches it might enable autocommands or mappings that the previous client did not support
---@param client vim.lsp.Client the lsp client
---@param bufnr number
local function on_attach(client, bufnr)
  local ar_lsp = ar_config.lsp
  setup_autocommands(client, bufnr)
  setup_mappings(client, bufnr)
  setup_lsp_stop_detached()
  if ar_lsp.foldexpr.enable then setup_lsp_foldexpr(client) end
  setup_semantic_tokens(client, bufnr)
  setup_colors(client, bufnr)
  setup_lsp_plugins(client, bufnr)
  if ar_config.ai.completion.variant == 'builtin' then
    setup_inline_completion(client, bufnr)
  end
  if ar_config.completion.variant == 'omnifunc' then
    setup_completion(client, bufnr)
    require('ar.compl')(client, bufnr)
  end
end

augroup('LspSetupAutoCommands', {
  event = { 'LspAttach' },
  desc = 'setup the language server autocommands',
  command = function(args)
    if vim.b[args.buf].is_large_file then
      vim.schedule(
        function() lsp.buf_detach_client(args.buf, args.data.client_id) end
      )
      return
    end
    local client = lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    on_attach(client, args.buf)
    local overrides = client_overrides[client.name]
    if not overrides or not overrides.on_attach then return end
    overrides.on_attach(client, args.buf)
  end,
}, {
  event = { 'LspDetach' },
  desc = 'cleanup the language server autocommands',
  command = 'setl foldexpr<',
}, {
  event = 'DiagnosticChanged',
  desc = 'Update the diagnostic locations',
  command = function(args)
    if not ar_config.lsp.omnifunc.enable then
      diagnostic.setloclist({ open = false })
    end
    if ar.falsy(args.data) or not args.data.diagnostics then return end
    if #args.data.diagnostics == 0 then vim.cmd('silent! lclose') end
  end,
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
    [S.WARN] = kind and fmt('DiagnosticSignWarn%s', kind) or diag_icons.warn,
    [S.INFO] = kind and fmt('DiagnosticSignInfo%s', kind) or diag_icons.info,
    [S.HINT] = kind and fmt('DiagnosticSignHint%s', kind) or diag_icons.hint,
    [S.ERROR] = kind and fmt('DiagnosticSignError%s', kind) or diag_icons.error,
  }
end

function ar.get_lsp_signs()
  return {
    text = get_signs(),
    texthl = get_signs(''),
    numhl = get_signs('Nr'),
    culhl = get_signs('CursorNr'),
    linehl = get_signs('Line'),
  }
end

local virtual_lines_variant = ar_config.lsp.virtual_lines.variant

diagnostic.config({
  signs = ar_config.lsp.signs.enable and ar.get_lsp_signs() or false,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_lines = virtual_lines_variant == 'builtin',
  virtual_text = ar_config.lsp.virtual_text.enable
      and {
        spacing = 1,
        -- BUG: when set to true, virtual text override does not work (severe diagnostics are not shown first)
        current_line = false,
        prefix = '',
        format = function(d)
          -- Use shorter, nicer names for some sources:
          local special_sources = {
            ['Lua Diagnostics.'] = 'lua',
            ['Lua Syntax Check.'] = 'lua',
          }
          local level = diagnostic.severity[d.severity]
          local message = diag_icons[level:lower()]
          if d.source then
            message = string.format(
              '%s %s',
              message,
              special_sources[d.source] or d.source
            )
          end
          if d.code then message = string.format('%s[%s]', message, d.code) end
          return message
        end,
      }
    or false,
  float = {
    max_width = max_width,
    max_height = max_height,
    border = border, --[[@diagnostic disable-line: assign-type-mismatch]]
    title = {
      { '  ', 'DiagnosticFloatTitleIcon' },
      { 'Problems  ', 'DiagnosticFloatTitle' },
    },
    focusable = false,
    scope = 'cursor',
    source = true,
    prefix = function(diag)
      local level = diagnostic.severity[diag.severity]
      local prefix = fmt('%s ', diag_icons[level:lower()])
      return prefix, 'Diagnostic' .. level:gsub('^%l', string.upper)
    end,
  },
})

-- Override the virtual text diagnostic handler so that the most severe diagnostic is shown first.
local show_handler = diagnostic.handlers.virtual_text.show
assert(show_handler)
local hide_handler = diagnostic.handlers.virtual_text.hide
diagnostic.handlers.virtual_text = {
  show = function(ns, bufnr, diagnostics, opts)
    table.sort(
      diagnostics,
      function(diag1, diag2) return diag1.severity > diag2.severity end
    )
    return show_handler(ns, bufnr, diagnostics, opts)
  end,
  hide = hide_handler,
}

-- local show_signs_handler = diagnostic.handlers.signs.show
-- assert(show_signs_handler)
-- local hide_signs_handler = diagnostic.handlers.signs.hide
-- diagnostic.handlers.signs = {
--   show = function(ns, bufnr, diagnostics, opts)
--     if not ar_config.lsp.signs.enable then return end
--     local max_severity_per_line = vim
--       .iter(diagnostics)
--       :fold({}, function(diag_map, d)
--         local m = diag_map[d.lnum]
--         if not m or d.severity < m.severity then diag_map[d.lnum] = d end
--         return diag_map
--       end)
--     return show_signs_handler(ns, bufnr, vim.tbl_values(max_severity_per_line), opts)
--   end,
--   hide = hide_signs_handler,
-- }

if not ar.is_available('noice.nvim') then
  local hover = lsp.buf.hover
  ---@diagnostic disable-next-line: duplicate-set-field
  lsp.buf.hover = function()
    return hover({
      border = border,
      max_width = max_width,
      max_height = max_height,
    })
  end

  local signature_help = lsp.buf.signature_help
  ---@diagnostic disable-next-line: duplicate-set-field
  lsp.buf.signature_help = function()
    return signature_help({
      border = border,
      max_width = max_width,
      max_height = max_height,
    })
  end

  lsp.handlers['window/showMessage'] = function(_, result, ctx)
    local client = lsp.get_client_by_id(ctx.client_id)
    if not client then return end
    local lvl = ({ 'ERROR', 'WARN', 'INFO', 'DEBUG' })[result.type]
    vim.notify(result.message, lvl, {
      title = 'LSP | ' .. client.name,
      timeout = 8000,
      keep = function() return lvl == 'ERROR' or lvl == 'WARN' end,
    })
  end
end
--------------------------------------------------------------------------------
-- LSP Progress
--------------------------------------------------------------------------------
if
  ar_config.lsp.progress.enable
  and ar_config.lsp.progress.variant == 'builtin'
then
  require('ar.lsp_progress')
end
