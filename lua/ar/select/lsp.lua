local api, fn = vim.api, vim.fn
local diagnostic = vim.diagnostic
local ts_lsp = ar.config.lsp.lang.typescript

local bool2str = ar.bool2str
local icons = ar.ui.codicons

local M = {}

function M.lsp_clients(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  return vim.tbl_filter(
    function(client) return client.name ~= 'copilot' end,
    clients
  )
end

local function lsp_notify(msg, type)
  vim.schedule(
    function() vim.notify(msg, type, { title = 'Diagnostic Toggles' }) end
  )
end

function M.eslint_fix()
  if fn.executable('eslint_d') > 0 then
    vim.cmd('!eslint_d --fix ' .. fn.expand('%:p'))
  else
    vim.notify('eslint_d is not installed')
  end
end

function M.lsp_restart_all()
  -- get clients that would match this buffer but aren't connected
  local other_matching_configs =
    require('ar.utils.lsp').get_other_matching_providers(vim.bo.filetype)
  -- first restart the existing clients
  for _, client in ipairs(require('ar.utils.lsp').get_managed_clients()) do
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
  local timer = assert(vim.uv.new_timer())
  local DEBOUNCE_MS = 500
  ar.augroup('Lint', {
    event = { 'BufEnter', 'BufWritePost', 'TextChanged', 'InsertLeave' },
    command = function(arg)
      timer:stop()
      timer:start(
        DEBOUNCE_MS,
        0,
        vim.schedule_wrap(function()
          if api.nvim_buf_is_valid(arg.buf) then
            api.nvim_buf_call(
              arg.buf,
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
  ---@diagnostic disable-next-line: undefined-field
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
  lsp_notify(string.format(
    'virtual lines %s',
    ---@diagnostic disable-next-line: undefined-field
    bool2str(type(diagnostic.config().virtual_lines) ~= 'boolean')
  ))
end

function M.toggle_diagnostics()
  local enabled = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not enabled)
  lsp_notify(string.format('diagnostics %s', bool2str(not enabled)))
end

function M.toggle_inline_completion()
  local enabled = vim.lsp.inline_completion.is_enabled()
  vim.lsp.inline_completion.enable(not enabled)
  lsp_notify(string.format('inline completion %s', bool2str(not enabled)))
end

function M.toggle_signs()
  local config = diagnostic.config()
  if type(config and config.signs) == 'boolean' then
    config = vim.tbl_extend('force', config, {
      signs = ar.get_lsp_signs(),
    })
  else
    config = vim.tbl_extend('force', config, { signs = false })
  end
  ar.config.lsp.signs.enable = not ar.config.lsp.signs.enable
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
  ar.config.lsp.hover_diagnostics.enable =
    not ar.config.lsp.hover_diagnostics.enable
  lsp_notify(
    string.format(
      'hover diagnostics %s',
      bool2str(ar.config.lsp.hover_diagnostics.enable)
    )
  )
end

function M.toggle_hover_diagnostics_go_to()
  ar.config.lsp.hover_diagnostics.go_to =
    not ar.config.lsp.hover_diagnostics.go_to
  lsp_notify(
    string.format(
      'hover diagnostics (go_to) %s',
      bool2str(ar.config.lsp.hover_diagnostics.go_to)
    )
  )
end

function M.toggle_format_on_save()
  ar.config.lsp.format_on_save.enable = not ar.config.lsp.format_on_save.enable
  lsp_notify(
    string.format(
      'format on save %s',
      bool2str(ar.config.lsp.format_on_save.enable)
    )
  )
end

function M.apply_biome_fixes()
  local actions = { 'source.fixAll.biome' }
  for i = 1, #actions do
    vim.defer_fn(function()
      vim.lsp.buf.code_action({
        ---@diagnostic disable-next-line: missing-fields, assign-type-mismatch
        context = { only = { actions[i] } },
        apply = true,
      })
    end, i * 100)
  end
end

function M.organize_imports()
  if ar.has('typescript-tools.nvim') then
    vim.cmd('TSToolsOrganizeImports')
  elseif ar.has('nvim-vtsls') then
    vim.cmd('VtsExec organize_imports')
  elseif ts_lsp['ts_ls'] then
    vim.cmd('OrganizeImports')
  end
end

function M.add_missing_imports()
  if ar.has('typescript-tools.nvim') then
    vim.cmd('TSToolsAddMissingImports')
  elseif ar.has('nvim-vtsls') then
    vim.cmd('VtsExec add_missing_imports')
  elseif ts_lsp['ts_ls'] then
    vim.cmd('AddMissingImports')
  end
end

function M.remove_unused()
  if ar.has('typescript-tools.nvim') then
    vim.cmd('TSToolsRemoveUnused')
  elseif ar.has('nvim-vtsls') then
    vim.cmd('VtsExec remove_unused')
  elseif ts_lsp['ts_ls'] then
    vim.cmd('RemoveUnused')
  end
end

function M.remove_unused_imports()
  if ar.has('typescript-tools.nvim') then
    vim.cmd('TSToolsRemoveUnusedImports')
  elseif ar.has('nvim-vtsls') then
    vim.cmd('VtsExec remove_unused_imports')
  end
end

function M.fix_all()
  if ar.has('typescript-tools.nvim') then
    vim.cmd('TSToolsFixAll')
  elseif ar.has('nvim-vtsls') then
    vim.cmd('VtsExec fix_all')
  end
end

return M
