if not rvim or rvim.none then return end

local cwd = vim.fn.getcwd()

local disabled = not rvim.lsp.enable
  or not rvim.plugins.enable
  or rvim.plugins.minimal
  or (cwd and rvim.dirs_match(rvim.lsp.disabled.directories, cwd))

if disabled then return end

local lsp, fn, api, fmt = vim.lsp, vim.fn, vim.api, string.format
local L = vim.lsp.log_levels
local M = vim.lsp.protocol.Methods
local conform = rvim.is_available('conform.nvim')

local diagnostic = vim.diagnostic
local augroup, icons, border =
  rvim.augroup, rvim.ui.codicons.lsp, rvim.ui.current.border

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

local handler = lsp.handlers['textDocument/publishDiagnostics']
---@diagnostic disable-next-line: duplicate-set-field
lsp.handlers['textDocument/publishDiagnostics'] = function(
  err,
  result,
  ctx,
  config
)
  result.diagnostics = vim.tbl_map(show_related_locations, result.diagnostics)
  handler(err, result, ctx, config)
end

--------------------------------------------------------------------------------
-- Mappings
--------------------------------------------------------------------------------
---Setup mapping when an lsp attaches to a buffer
---@param client lsp.Client
---@param bufnr integer
local function setup_mappings(client, bufnr)
  local function prev_diagnostic()
    return function()
      diagnostic.goto_prev({
        float = rvim.lsp.hover_diagnostics.go_to
          and not rvim.lsp.hover_diagnostics.enable,
      })
    end
  end
  local function next_diagnostic()
    return function()
      diagnostic.goto_next({
        float = rvim.lsp.hover_diagnostics.go_to
          and not rvim.lsp.hover_diagnostics.enable,
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
      function() lsp.inlay_hint(0) end,
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
    then
      map(m[1], m[2], m[3], { buffer = bufnr, desc = fmt('lsp: %s', m.desc) })
    end
  end)
end

--------------------------------------------------------------------------------
-- LSP SETUP/TEARDOWN
--------------------------------------------------------------------------------

---@alias ClientOverrides {on_attach: fun(client: lsp.Client, bufnr: number), semantic_tokens: fun(bufnr: number, client: lsp.Client, token: table)}

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
    command = function(args)
      overrides.semantic_tokens(args.buf, client, args.data.token)
    end,
  })
end

---@param client lsp.Client
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
    vim.lsp.inlay_hint.enable(buf, true)
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
      command = 'silent! lua vim.lsp.codelens.refresh()',
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
---@param client lsp.Client the lsp client
---@param bufnr number
local function on_attach(client, bufnr)
  setup_autocommands(client, bufnr)
  setup_mappings(client, bufnr)
  setup_semantic_tokens(client, bufnr)
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
--------------------------------------------------------------------------------
-- Signs
--------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------//
-- Handler Overrides
-----------------------------------------------------------------------------//
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

diagnostic.config({
  signs = rvim.lsp.signs.enable,
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
    source = 'always',
    prefix = function(diag)
      local level = diagnostic.severity[diag.severity]
      local prefix = fmt('%s ', icons[level:lower()])
      return prefix, 'Diagnostic' .. level:gsub('^%l', string.upper)
    end,
  },
})
--------------------------------------------------------------------------------
-- LSP Progress
--------------------------------------------------------------------------------
-- ref: https://github.com/rockyzhang24/dotfiles/blob/master/.config/nvim/lua/rockyz/lsp/progress.lua

-- Buffer number and window id for the floating window

rvim.lsp.progess = {
  bufnr = nil,
  winid = nil,
  spinner = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
  idx = 0,
  is_done = true,
}

-- Get the progress message for all clients. The format is
-- "65%: [lua_ls] Loading Workspace: 123/1500 | [client2] xxx | [client3] xxx"
local function get_lsp_progress_msg()
  -- Most code is grabbed from the source of vim.lsp.status()
  -- Ref: https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp.lua
  local percentage = nil
  local all_messages = {}
  rvim.lsp.progess.is_done = true
  for _, client in ipairs(vim.lsp.get_clients()) do
    local messages = {}
    for progress in client.progress do
      local value = progress.value
      if type(value) == 'table' and value.kind then
        if value.kind ~= 'end' then rvim.lsp.progess.is_done = false end
        local message = value.message and (value.title .. ': ' .. value.message)
          or value.title
        messages[#messages + 1] = message
        if value.percentage then
          percentage = math.max(percentage or 0, value.percentage)
        end
      end
    end
    if next(messages) ~= nil then
      table.insert(
        all_messages,
        '[' .. client.name .. '] ' .. table.concat(messages, ', ')
      )
    end
  end
  local message = table.concat(all_messages, ' | ')
  -- Show percentage
  if percentage then
    message = string.format('%3d%%: %s', percentage, message)
  end
  -- Show spinner
  rvim.lsp.progess.idx = rvim.lsp.progess.idx == #rvim.lsp.progess.spinner * 4
      and 1
    or rvim.lsp.progess.idx + 1
  message = rvim.lsp.progess.spinner[math.ceil(rvim.lsp.progess.idx / 4)]
    .. message
  return message
end

rvim.augroup('CustomLspProgress', {
  event = 'LspProgress',
  pattern = '*',
  command = function()
    -- The row position of the floating window. Just right above the status line.
    local win_row = vim.o.lines - vim.o.cmdheight - 4
    local message = get_lsp_progress_msg()
    if
      rvim.lsp.progess.winid == nil
      or not api.nvim_win_is_valid(rvim.lsp.progess.winid)
      or api.nvim_win_get_tabpage(rvim.lsp.progess.winid)
        ~= api.nvim_get_current_tabpage()
    then
      rvim.lsp.progess.bufnr = api.nvim_create_buf(false, true)
      rvim.lsp.progess.winid =
        api.nvim_open_win(rvim.lsp.progess.bufnr, false, {
          relative = 'editor',
          width = #message,
          height = 1,
          row = win_row,
          col = vim.o.columns - #message,
          style = 'minimal',
          noautocmd = true,
          border = border,
        })
    else
      api.nvim_win_set_config(rvim.lsp.progess.winid, {
        relative = 'editor',
        width = #message,
        row = win_row,
        col = vim.o.columns - #message,
      })
    end
    vim.wo[rvim.lsp.progess.winid].winhl = 'NormalFloat:NormalFloat'
    api.nvim_buf_set_lines(rvim.lsp.progess.bufnr, 0, 1, false, { message })
    if rvim.lsp.progess.is_done then
      if api.nvim_win_is_valid(rvim.lsp.progess.winid) then
        api.nvim_win_close(rvim.lsp.progess.winid, true)
      end
      if api.nvim_buf_is_valid(rvim.lsp.progess.bufnr) then
        api.nvim_buf_delete(rvim.lsp.progess.bufnr, { force = true })
      end
      rvim.lsp.progess.winid = nil
      rvim.lsp.progess.idx = 0
    end
  end,
})
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
--------------------------------------------------------------------------------
-- Light Bulb
--------------------------------------------------------------------------------
-- Show a lightbulb when code actions are available at the cursor
--
-- It is shown at the beginning (the first column) of the same line, or the
-- previous line if the space is not enough.
--

rvim.lsp.lightbulb = {
  bulb_buffer = nil,
  prev_lnum = nil,
  prev_topline_num = nil,
  prev_bufnr = nil,
  code_action_support = false,
}

local function remove_bulb()
  if rvim.lsp.lightbulb.bulb_buffer ~= nil then
    vim.cmd(('noautocmd bwipeout %d'):format(rvim.lsp.lightbulb.bulb_buffer))
    rvim.lsp.lightbulb.bulb_buffer = nil
  end
end

local function show_lightbulb()
  -- Check if the method textDocument/codeAction is supported
  local cur_bufnr = vim.api.nvim_get_current_buf()
  if cur_bufnr ~= rvim.lsp.lightbulb.prev_bufnr then -- when entering to another buffer
    rvim.lsp.lightbulb.prev_bufnr = cur_bufnr
    rvim.lsp.lightbulb.code_action_support = false
  end
  if rvim.lsp.lightbulb.code_action_support == false then
    for _, client in pairs(vim.lsp.get_clients({ bufnr = cur_bufnr })) do
      if client then
        if client.supports_method('textDocument/codeAction') then
          rvim.lsp.lightbulb.code_action_support = true
        end
      end
    end
  end
  if rvim.lsp.lightbulb.code_action_support == false then
    remove_bulb()
    return
  end
  local context = {
    -- Get the diagnostics at the cursor
    diagnostics = rvim.lsp.get_diagnostic_at_cursor(),
  }
  local params = vim.lsp.util.make_range_params()
  params.context = context
  -- Send request to the server to check if a code action is available at the
  -- cursor
  vim.lsp.buf_request_all(
    0,
    'textDocument/codeAction',
    params,
    function(results)
      local has_actions = false
      for _, result in pairs(results) do
        for _, action in pairs(result.result or {}) do
          if action then
            has_actions = true
            break
          end
        end
      end
      if has_actions then
        -- Avoid bulb icon flashing when move the cursor in a line
        --
        -- When code actions are available in different positions within a line,
        -- the bulb will be shown in the same place, so no need to remove the
        -- previous bulb and create a new one.
        -- Check if the first line of the screen is changed in order to update the
        -- bulb when scroll the window (e.g., C-y, C-e, zz, etc)
        local cur_lnum = vim.fn.line('.')
        local cur_topline_num = vim.fn.line('w0')
        if
          cur_lnum == rvim.lsp.lightbulb.prev_lnum
          and cur_topline_num == rvim.lsp.lightbulb.prev_topline_num
          and rvim.lsp.lightbulb.bulb_buffer ~= nil
        then
          return
        end
        -- Remove the old bulb if necessary, and then create a new bulb
        remove_bulb()
        rvim.lsp.lightbulb.prev_lnum = cur_lnum
        rvim.lsp.lightbulb.prev_topline_num = cur_topline_num
        local icon = rvim.ui.icons.misc.lightbulb
        -- Calculate the row position of the lightbulb relative to the cursor
        local row = 0
        local cur_indent = vim.fn.indent('.')
        if cur_indent <= 2 then
          if vim.fn.line('.') == vim.fn.line('w0') then
            row = 1
          else
            row = -1
          end
        end
        -- Calculate the col position of the lightbulb relative to the cursor
        --
        -- NOTE: We want to get how many columns (characters) before the cursor
        -- that will be the offset for placing the bulb. If the indent is TAB,
        -- each indent level is counted as a single one character no matter how
        -- many spaces the TAB has. We need to convert it to the number of spaces.
        local cursor_col = vim.fn.col('.')
        local col = -cursor_col + 1
        if not vim.api.nvim_get_option_value('expandtab', {}) then
          local tabstop = vim.api.nvim_get_option_value('tabstop', {})
          local tab_cnt = cur_indent / tabstop
          if cursor_col <= tab_cnt then
            col = -(cursor_col - 1) * tabstop
          else
            col = -(cursor_col - tab_cnt + cur_indent) + 1
          end
        end
        rvim.lsp.lightbulb.bulb_buffer = vim.api.nvim_create_buf(false, true)
        local winid =
          vim.api.nvim_open_win(rvim.lsp.lightbulb.bulb_buffer, false, {
            relative = 'cursor',
            width = 1,
            height = 1,
            row = row,
            col = col,
            style = 'minimal',
            noautocmd = true,
          })
        vim.wo[winid].winhl = 'Normal:LightBulb'
        vim.api.nvim_buf_set_lines(
          rvim.lsp.lightbulb.bulb_buffer,
          0,
          1,
          false,
          { icon }
        )
        return
      end
      -- If no actions, remove the bulb if it is existing
      if has_actions == false then remove_bulb() end
    end
  )
end

rvim.augroup('code_action', {
  event = { 'CursorHold', 'CursorHoldI', 'WinScrolled' },
  pattern = '*',
  command = show_lightbulb,
}, {
  event = { 'TermEnter' },
  pattern = '*',
  command = remove_bulb,
})
