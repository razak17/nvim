local api, fn = vim.api, vim.fn
local diagnostic = vim.diagnostic
local pickers = require('telescope.pickers')
local entry_display = require('telescope.pickers.entry_display')
local finders = require('telescope.finders')
local conf = require('telescope.config').values

local bool2str = rvim.bool2str
local icons = rvim.ui.codicons

local M = {}

function M.lsp_clients(bufnr) return vim.lsp.get_clients({ bufnr = bufnr }) end

local function lsp_notify(msg, type)
  vim.schedule(
    function() vim.notify(msg, type, { title = 'Diagnostic Toggles' }) end
  )
end

function M.format_buf()
  if #M.lsp_clients(0) > 0 then
    vim.lsp.buf.format()
  elseif vim.bo.filetype == 'json' then
    vim.cmd(':%!prettier --parser json')
  elseif vim.bo.filetype == 'typescript' then
    vim.cmd(':%!prettier --parser typescript')
  elseif vim.bo.filetype == 'html' then
    vim.cmd(':%!prettier --parser html')
  elseif vim.bo.filetype == 'sql' then
    vim.cmd(':%!npx sql-formatter --language postgresql')
  else
    print('No LSP and unhandled filetype ' .. vim.bo.filetype)
  end
end

function M.eslint_fix()
  if fn.executable('eslint_d') > 0 then
    vim.cmd('!eslint_d --fix ' .. fn.expand('%:p'))
  else
    vim.notify('eslint_d is not installed')
  end
end

local function lsp_check_capabilities(feature, bufnr)
  local clients = M.lsp_clients(bufnr)
  for _, client in pairs(clients) do
    if client.server_capabilities[feature] then return true end
  end
  return false
end

function M.display_lsp_references()
  if lsp_check_capabilities('callHierarchyProvider', 0) then
    vim.lsp.buf_request(
      0,
      'textDocument/prepareCallHierarchy',
      vim.lsp.util.make_position_params(),
      function(_, result)
        if result ~= nil and #result >= 1 then
          local call_hierarchy_item = result[1]
          vim.lsp.buf_request(
            0,
            'callHierarchy/incomingCalls',
            { item = call_hierarchy_item },
            function(_, res, _, _)
              if #res > 0 then
                require('telescope.builtin').lsp_incoming_calls({
                  path_display = { 'tail' },
                })
                return
              end
            end
          )
        end
      end
    )
  end
  require('telescope.builtin').lsp_references({ path_display = { 'tail' } })
end

function M.lsp_restart_all()
  -- get clients that would match this buffer but aren't connected
  local other_matching_configs =
    require('lspconfig.util').get_other_matching_providers(vim.bo.filetype)
  -- first restart the existing clients
  for _, client in ipairs(require('lspconfig.util').get_managed_clients()) do
    client.stop()
    vim.defer_fn(
      function() require('lspconfig.configs')[client.name].launch() end,
      500
    )
  end
  -- now restart those that were not connected
  for _, client in ipairs(other_matching_configs) do
    vim.defer_fn(
      function() require('lspconfig.configs')[client.name].launch() end,
      500
    )
  end
  -- handle null-ls separately as it's not managed by lspconfig
  local nullls_client = require('null-ls.client').get_client()
  if nullls_client ~= nil then nullls_client.stop() end
  vim.defer_fn(function() require('null-ls.client').try_add() end, 500)
  local current_top_line = fn.line('w0')
  local current_line = fn.line('.')
  if vim.bo.modified then
    vim.cmd(
      [[echohl ErrorMsg | echo "Reload will work better if you save the file & re-trigger" | echohl None]]
    )
  else
    vim.cmd([[edit]])
  end
  -- edit can move the scrollpos, restore it
  vim.cmd(':' .. current_top_line)
  vim.cmd('norm! zt') -- set to top of window
  vim.cmd(':' .. current_line)
end

local function nvim_lint_create_autocmds()
  local lint = require('lint')
  -- lifted from https://github.com/stevearc/dotfiles/blob/master/.config/nvim/lua/plugins/lint.lua
  -- also see https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/linting.lua
  -- ref: https://github.com/emmanueltouzery/nvim_config/blob/main/init.lua#L32
  local uv = vim.uv or vim.loop
  local timer = assert(uv.new_timer())
  local DEBOUNCE_MS = 500
  rvim.augroup('Lint', {
    event = { 'BufEnter', 'BufWritePost', 'TextChanged', 'InsertLeave' },
    command = function()
      local bufnr = api.nvim_get_current_buf()
      timer:stop()
      timer:start(
        DEBOUNCE_MS,
        0,
        vim.schedule_wrap(function()
          if api.nvim_buf_is_valid(bufnr) then
            api.nvim_buf_call(
              bufnr,
              function() lint.try_lint(nil, { ignore_errors = true }) end
            )
          end
        end)
      )
    end,
  })
end

function M.toggle_linting()
  local lint_aucmds = api.nvim_get_autocmds({ group = 'Lint' })
  local is_disable = lint_aucmds ~= nil and #lint_aucmds > 0
  if is_disable then
    vim.notify('Disabling linting')
  else
    vim.notify('Enabling linting')
  end

  if is_disable then
    -- the reason i do app-wide and not buffer-wide is because of this,
    -- can't disable autocmds only for the current buffer that i can see.
    -- probably should use nvim_del_augroup_by_name() as well, but for now this works
    vim.cmd('au! Lint')
    for i, ns in pairs(vim.diagnostic.get_namespaces()) do
      if not string.match(ns.name, 'vim.lsp') then
        -- https://github.com/neovim/neovim/issues/25131
        vim.diagnostic.reset(i)
      end
    end
  else
    nvim_lint_create_autocmds()
    api.nvim_exec_autocmds('BufEnter', { group = 'Lint' })
  end
end

function M.toggle_virtual_text()
  local config = diagnostic.config()
  if config and type(config.virtual_text) == 'boolean' then
    config = vim.tbl_extend('force', config, {
      virtual_text = {
        spacing = 1,
        prefix = function(d)
          local level = diagnostic.severity[d.severity]
          return icons[level:lower()]
        end,
      },
    })
    if type(config.virtual_lines) == 'table' then
      config = vim.tbl_extend('force', config, { virtual_lines = false })
    end
  else
    config = vim.tbl_extend('force', config, { virtual_text = false })
  end
  diagnostic.config(config)
  lsp_notify(
    string.format(
      'virtual text %s',
      bool2str(type(diagnostic.config().virtual_text) ~= 'boolean')
    )
  )
end

function M.toggle_virtual_lines()
  local config = diagnostic.config()
  if type(config and config.virtual_lines) == 'boolean' then
    config = vim.tbl_extend(
      'force',
      config,
      { virtual_lines = { only_current_line = true } }
    )
    if type(config.virtual_text) == 'table' then
      config = vim.tbl_extend('force', config, { virtual_text = false })
    end
  else
    config = vim.tbl_extend('force', config, { virtual_lines = false })
  end
  diagnostic.config(config)
  lsp_notify(
    string.format(
      'virtual lines %s',
      bool2str(type(diagnostic.config().virtual_lines) ~= 'boolean')
    )
  )
end

function M.toggle_diagnostics()
  local enabled = true
  if vim.diagnostic.is_disabled then
    enabled = not vim.diagnostic.is_disabled()
  end
  enabled = not enabled

  if enabled then
    vim.diagnostic.enable()
  else
    vim.diagnostic.disable()
  end

  lsp_notify(string.format('diagnostics %s', bool2str(enabled)))
end

function M.toggle_signs()
  local config = diagnostic.config()
  if type(config and config.signs) == 'boolean' then
    config = vim.tbl_extend('force', config, {
      signs = rvim.get_lsp_signs(),
    })
  else
    config = vim.tbl_extend('force', config, { signs = false })
  end
  rvim.lsp.signs.enable = not rvim.lsp.signs.enable
  diagnostic.config(config)
  vim.cmd('edit | silent! wall') -- Redraw
  lsp_notify(
    string.format(
      'signs %s',
      bool2str(type(diagnostic.config().signs) ~= 'boolean')
    )
  )
end

function M.toggle_hover_diagnostics()
  rvim.lsp.hover_diagnostics.enable = not rvim.lsp.hover_diagnostics.enable
  lsp_notify(
    string.format(
      'hover diagnostics %s',
      bool2str(rvim.lsp.hover_diagnostics.enable)
    )
  )
end

function M.toggle_hover_diagnostics_go_to()
  rvim.lsp.hover_diagnostics.go_to = not rvim.lsp.hover_diagnostics.go_to
  lsp_notify(
    string.format(
      'hover diagnostics (go_to) %s',
      bool2str(rvim.lsp.hover_diagnostics.go_to)
    )
  )
end

function M.toggle_format_on_save()
  rvim.lsp.format_on_save.enable = not rvim.lsp.format_on_save.enable
  lsp_notify(
    string.format('format on save %s', bool2str(rvim.lsp.format_on_save.enable))
  )
end

--------------------------------------------------------------------------------
-- Call Hierarchy
--------------------------------------------------------------------------------
local function get_call_hierarchy_for_item(call_hierarchy_item)
  local call_tree = {}
  -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#callHierarchy_incomingCalls
  local by_lsp = vim.lsp.buf_request_sync(
    0,
    'callHierarchy/incomingCalls',
    { item = call_hierarchy_item }
  )
  if #by_lsp >= 1 and by_lsp then
    local result = by_lsp[vim.tbl_keys(by_lsp)[1]].result
    if #result >= 1 then
      for _, item in ipairs(result) do
        -- "group by" URL, because two calling classes/functions could have the same name,
        -- but different URIs/being distinct. If we grouped by name, we'd merge them.
        call_tree[item.from.uri] = {
          item = item,
          nested_hierarchy = get_call_hierarchy_for_item(item.from),
        }
      end
    end
  end
  return call_tree
end

local function print_hierarchy(item, depth, res)
  local prefix = string.rep(' ', depth)
  if depth > 0 then prefix = prefix .. '󰘍 ' end
  for _, nested_h in pairs(item.nested_hierarchy) do
    print_hierarchy(nested_h, depth + 1, res)
  end
  table.insert(
    res,
    { item = item, desc = prefix .. item.item.from.name, depth = depth }
  )
end

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_prepareCallHierarchy
function M.display_call_hierarchy()
  local displayer = entry_display.create({
    separator = ' ',
    items = {
      { width = 35 },
      { remaining = true },
    },
  })

  local make_display = function(entry)
    return displayer({
      { entry.name, 'TelescopeResultsIdentifier' },
      { entry.path:match('[^/]+/[^/]+$'), 'Special' },
    })
  end

  local make_display_nested = function(entry)
    return displayer({
      { entry.name, 'TelescopeResultsFunction' },
      { entry.path:match('[^/]+/[^/]+$'), 'Special' },
    })
  end

  local by_lsp = vim.lsp.buf_request_sync(
    0,
    'textDocument/prepareCallHierarchy',
    vim.lsp.util.make_position_params()
  )
  if by_lsp ~= nil and #by_lsp >= 1 then
    local result = by_lsp[vim.tbl_keys(by_lsp)[1]].result
    if #result >= 1 then
      local call_hierarchy_item = result[1]
      local call_tree = get_call_hierarchy_for_item(call_hierarchy_item)

      local data = {}
      for _, caller_info in pairs(call_tree) do
        print_hierarchy(caller_info, 0, data)
      end

      pickers
        .new({}, {
          prompt_title = 'Incoming calls: ' .. call_hierarchy_item.name,
          finder = finders.new_table({
            results = data,
            entry_maker = function(entry)
              -- print(vim.inspect(entry))
              entry.name = entry.desc
              entry.ordinal = entry.desc
              if entry.depth ~= nil and entry.depth > 0 then
                entry.display = make_display_nested
              else
                entry.display = make_display
              end
              entry.path = entry.item.item.from.uri:gsub('^file:..', '')
              entry.lnum = entry.item.item.fromRanges[1].start.line + 1
              return entry
            end,
          }),
          previewer = conf.grep_previewer({}),
        })
        :find()
    end
  end
end

return M
