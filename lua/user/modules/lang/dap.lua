local M = {
  'mfussenegger/nvim-dap',
  version = '*',
  dependencies = {
    {
      'mxsdev/nvim-dap-vscode-js',
      config = function()
        require('dap-vscode-js').setup({
          node_path = 'node',
          debugger_path = rvim.get_runtime_dir() .. '/site/lazy/vscode-js-debug',
          log_file_path = rvim.get_cache_dir() .. '/dap_vscode_js.log',
          adapters = {
            'pwa-node',
            'pwa-chrome',
            'pwa-msedge',
            'node-terminal',
            'pwa-extensionHost',
          },
        })
      end,
    },
    { 'microsoft/vscode-js-debug', build = 'npm install --legacy-peer-deps && npm run compile' },
    {
      'rcarriga/nvim-dap-ui',
      init = function()
        rvim.nnoremap(
          '<localleader>du',
          function() require('dapui').toggle({ reset = true }) end,
          'dapui: toggle'
        )
      end,
      config = function()
        require('dapui').setup({
          windows = { indent = 2 },
          floating = { border = rvim.ui.current.border },
        })
        local dapui = require('dapui')
        local dap = require('dap')
        -- NOTE: this opens dap UI automatically when dap starts
        dap.listeners.after.event_initialized['dapui_config'] = function()
          dapui.open()
          vim.api.nvim_exec_autocmds('User', { pattern = 'DapStarted' })
        end
        dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
        dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
      end,
    },
    {
      'theHamsta/nvim-dap-virtual-text',
      config = function()
        require('nvim-dap-virtual-text').setup({
          enabled = true,
          enabled_commands = true,
          highlight_changed_variables = true,
          all_frames = true,
        })
      end,
    },
  },
}

function M.init()
  local function attach()
    print('attaching')
    require('dap').run({
      type = 'node2',
      request = 'attach',
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = 'inspector',
      skipFiles = { '<node_internals>/**/*.js' },
    })
  end

  local function attach_to_remote()
    print('attaching')
    require('dap').run({
      type = 'node2',
      request = 'attach',
      address = '127.0.0.1',
      port = 9229,
      localRoot = vim.fn.getcwd(),
      remoteRoot = '/home/vcap/app',
      sourceMaps = true,
      protocol = 'inspector',
      skipFiles = { '<node_internals>/**/*.js' },
    })
  end

  local function dap() return require('dap') end
  local function repl_toggle() dap.repl.toggle(nil, 'botright split') end
  local function set_breakpoint() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end
  local function hover() require('dap.ui.widgets').hover() end

  rvim.nnoremap('<localleader>db', dap().toggle_breakpoint, 'dap: toggle breakpoint')
  rvim.nnoremap('<localleader>dB', set_breakpoint, 'dap: set breakpoint')
  rvim.nnoremap('<localleader>dc', dap().continue, 'dap: continue or start debugging')
  rvim.nnoremap('<localleader>dC', dap().clear_breakpoints, 'dap: clear breakpoint')
  rvim.nnoremap('<localleader>dh', dap().step_back, 'dap: step back')
  rvim.nnoremap('<localleader>de', dap().step_out, 'dap: step out')
  rvim.nnoremap('<localleader>di', dap().step_into, 'dap: step into')
  rvim.nnoremap('<localleader>do', dap().step_over, 'dap: step over')
  rvim.nnoremap('<localleader>dl', dap().run_last, 'dap: run last')
  rvim.nnoremap('<localleader>dr', dap().restart, 'dap: restart')
  rvim.nnoremap('<localleader>dw', hover, 'dap: hover')
  rvim.nnoremap('<localleader>dx', dap().terminate, 'dap: terminate')
  rvim.nnoremap('<localleader>dt', repl_toggle, 'dap: toggle REPL')
  rvim.nnoremap('<localleader>da', attach, 'dap(node): attach')
  rvim.nnoremap('<localleader>dA', attach_to_remote, 'dap(node): attach to remote')
end

function M.config()
  local fn, icons = vim.fn, rvim.ui.icons
  local dap = require('dap')

  -- DON'T automatically stop at exceptions
  dap.defaults.fallback.exception_breakpoints = {}

  fn.sign_define('DapBreakpoint', {
    text = icons.misc.bug_alt,
    texthl = 'DapBreakpoint',
    linehl = '',
    numhl = '',
  })

  fn.sign_define('DapBreakpointRejected', {
    text = icons.misc.bug_alt,
    texthl = 'DapBreakpointRejected',
    linehl = '',
    numhl = '',
  })

  fn.sign_define('DapStopped', {
    text = icons.misc.dap_hollow,
    texthl = 'DapStopped',
    linehl = '',
    numhl = '',
  })

  -- python
  require('user.dap.python')
  -- go
  require('user.dap.go')
  -- typescript
  require('user.dap.typescript')
  -- Lua
  require('user.dap.lua')
  -- codelldb
  require('user.dap.rust')
end

return M
