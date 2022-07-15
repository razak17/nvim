return function()
  local dapui = require('dapui')
  require('dapui').setup()
  require('which-key').register({
    ['<localleader>dx'] = { dapui.close, 'dap-ui: close' },
    ['<localleader>do'] = { dapui.toggle, 'dap-ui: toggle' },
  })

  local dap = require('dap')
  -- NOTE: this opens dap UI automatically when dap starts
  dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open()
    vim.api.nvim_exec_autocmds('User', { pattern = 'DapStarted' })
  end
  dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
  dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
end
