if not rvim or not rvim.lsp.enable then return end

local function lsp_clients(bufnr) return vim.lsp.get_clients({ bufnr = bufnr }) end

local function format_buf()
  if #lsp_clients(0) > 0 then
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

local function eslint_fix()
  if vim.fn.executable('eslint_d') > 0 then
    vim.cmd('!eslint_d --fix ' .. vim.fn.expand('%:p'))
  else
    vim.notify('eslint_d is not installed')
  end
end

local function lsp_check_capabilities(feature, bufnr)
  local clients = lsp_clients(bufnr)
  for _, client in pairs(clients) do
    if client.server_capabilities[feature] then return true end
  end
  return false
end

local function display_lsp_references()
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

local function lsp_restart_all()
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
  local current_top_line = vim.fn.line('w0')
  local current_line = vim.fn.line('.')
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

local function enable_diagnostics(diag)
  for i, ns in pairs(vim.diagnostic.get_namespaces()) do
    if ns.name == diag then
      vim.diagnostic.enable(0, i)
      ---@diagnostic disable-next-line: assign-type-mismatch
      vim.b['disabled_dg_' .. i] = false
    end
  end
end

local function disable_diagnostics(diag)
  for i, ns in pairs(vim.diagnostic.get_namespaces()) do
    if ns.name == diag then
      vim.diagnostic.disable(0, i)
      ---@diagnostic disable-next-line: assign-type-mismatch
      vim.b['disabled_dg_' .. i] = true
    end
  end
end

local strings = require('plenary.strings')
local function telescope_enable_disable_diagnostics()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local buf_lsp_client_ids = {}
  for _, cl in pairs(vim.lsp.get_clients()) do
    buf_lsp_client_ids[cl.id] = true
  end

  local diagnostic_signs = {}
  for i, ns in pairs(vim.diagnostic.get_namespaces()) do
    if ns.user_data.sign_group then
      local id = tonumber(ns.name:gmatch('%d+$')()) -- extract the LSP id ... xxx.yy.123 -- id is 123
      if buf_lsp_client_ids[id] ~= nil then
        if vim.b['disabled_dg_' .. i] then
          table.insert(diagnostic_signs, 'Enable ' .. ns.name)
        else
          table.insert(diagnostic_signs, 'Disable ' .. ns.name)
        end
      end
    end
  end

  local opts = {
    layout_config = {
      height = 0.3,
      width = 0.3,
    },
  }

  pickers
    .new(opts, {
      prompt_title = 'LSP Diagnostics toggle',
      finder = finders.new_table({
        results = diagnostic_signs,
      }),
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local action_txt = selection[1]
          if action_txt:sub(1, #'Enable') == 'Enable' then
            enable_diagnostics(strings.strcharpart(action_txt, #'Enable '))
          else
            disable_diagnostics(strings.strcharpart(action_txt, #'Disable '))
          end
        end)
        return true
      end,
    })
    :find()
end

local diagnostic = vim.diagnostic
local bool2str = rvim.bool2str
local icons = rvim.ui.codicons

local function toggle_virtual_text()
  local config = diagnostic.config()
  if type(config.virtual_text) == 'boolean' then
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
  rvim.lsp.notify(
    string.format(
      'virtual text %s',
      bool2str(type(diagnostic.config().virtual_text) ~= 'boolean')
    )
  )
end

local function toggle_virtual_lines()
  local config = diagnostic.config()
  if type(config.virtual_lines) == 'boolean' then
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
  rvim.lsp.notify(
    string.format(
      'virtual lines %s',
      bool2str(type(diagnostic.config().virtual_lines) ~= 'boolean')
    )
  )
end

local function toggle_signs()
  local config = diagnostic.config()
  if type(config.signs) == 'boolean' then
    config =
      vim.tbl_extend('force', config, { signs = { severity_limit = 'Error' } })
  else
    config = vim.tbl_extend('force', config, { signs = false })
  end
  rvim.lsp.signs.enable = not rvim.lsp.signs.enable
  diagnostic.config(config)
  vim.cmd('edit | silent! wall') -- Redraw
  rvim.lsp.notify(
    string.format(
      'signs %s',
      bool2str(type(diagnostic.config().signs) ~= 'boolean')
    )
  )
end

local function toggle_hover_diagnostics()
  rvim.lsp.hover_diagnostics.enable = not rvim.lsp.hover_diagnostics.enable
  rvim.lsp.notify(
    string.format(
      'hover diagnostics %s',
      bool2str(rvim.lsp.hover_diagnostics.enable)
    )
  )
end

local lsp_options = {
  ['1. Code Format'] = format_buf,
  ['2. Eslint Fix'] = eslint_fix,
  ['3. LSP references'] = display_lsp_references,
  ['4. Call Heirarchy'] = 'lua rvim.telescope_display_call_hierarchy()',
  ['5. Remove Unused Imports'] = 'lua rvim.remove_unused_imports()',
  ['5. Restart All LSPs'] = lsp_restart_all,
  ['6. Toggle Diagnostics Sources for Buffer'] = telescope_enable_disable_diagnostics,
  ['7. Toggle Virtual Text'] = toggle_virtual_text,
  ['7. Toggle Virtual Lines'] = toggle_virtual_lines,
  ['7. Toggle Diagnostic Signs'] = toggle_signs,
  ['7. Toggle Hover Diagnostics'] = toggle_hover_diagnostics,
  ['7. Toggle JS Arrow Function'] = 'lua require("nvim-js-actions/js-arrow-fn").toggle()',
  ['8. Preview Code Actions'] = 'lua require("actions-preview").code_actions()',
}

local lsp_menu = function()
  if #lsp_clients(0) == 0 then
    vim.notify_once('there is no lsp server attached to the current buffer')
  else
    rvim.create_select_menu('Code/LSP actions', lsp_options)() --> extra paren to execute!
  end
end

map(
  'n',
  '<leader>ll',
  lsp_menu,
  { desc = '[l]sp [a]ctions: open menu for lsp features' }
)
