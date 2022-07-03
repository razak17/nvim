return function()
  local dap_ui_status_ok, dapui = pcall(require, 'dapui')
  if not dap_ui_status_ok then
    return
  end

  dapui.setup({
    icons = { expanded = '▾', collapsed = '▸' },
    floating = {
      max_height = nil, -- These can be integers or a float between 0 and 1.
      max_width = nil, -- Floats will be treated as percentage of your screen.
      border = 'single', -- Border style. Can be "single", "double" or "rounded"
      mappings = {
        close = { 'q', '<Esc>' },
      },
    },
    windows = { indent = 1 },
  })
  require('which-key').register({
    ['<localleader>dx'] = { dapui.close, 'dap-ui: close' },
    ['<localleader>do'] = { dapui.toggle, 'dap-ui: toggle' },
  })
  local dap = require('dap')
  -- NOTE: this opens dap UI automatically when dap starts
  dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open()
    vim.api.nvim_exec_autocmds('User', 'DapStarted')
  end
  dap.listeners.before.event_terminated['dapui_config'] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited['dapui_config'] = function()
    dapui.close()
  end
end
