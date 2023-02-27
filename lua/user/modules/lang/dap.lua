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

local function repl_toggle() require('dap').repl.toggle(nil, 'botright split') end
local function continue() require('dap').continue() end
local function step_out() require('dap').step_out() end
local function step_into() require('dap').step_into() end
local function step_over() require('dap').step_over() end
local function run_last() require('dap').run_last() end
local function step_back() require('dap').step_back() end
local function restart() require('dap').restart() end
local function terminate() require('dap').terminate() end
local function toggle_breakpoint() require('dap').toggle_breakpoint() end
local function clear_breakpoints() require('dap').clear_breakpoints() end
local function hover() require('dap.ui.widgets').hover() end
local function set_breakpoint()
  require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
end
local function log_breakpoint()
  require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
end

return {
  'mfussenegger/nvim-dap',
  keys = {
    { '<localleader>db', toggle_breakpoint, desc = 'dap: toggle breakpoint' },
    { '<localleader>dB', set_breakpoint, desc = 'dap: set conditional breakpoint' },
    { '<localleader>dc', continue, desc = 'dap: continue or start debugging' },
    { '<localleader>dC', clear_breakpoints, desc = 'dap: clear breakpoint' },
    { '<localleader>de', step_out, desc = 'dap: step out' },
    { '<localleader>dh', step_back, desc = 'dap: step back' },
    { '<localleader>di', step_into, desc = 'dap: step into' },
    { '<localleader>dl', run_last, desc = 'dap REPL: run last' },
    { '<localleader>dL', log_breakpoint, desc = 'dap: log breakpoint' },
    { '<localleader>do', step_over, desc = 'dap: step over' },
    { '<localleader>dr', restart, desc = 'dap: restart' },
    { '<localleader>dw', hover, desc = 'dap: hover' },
    { '<localleader>dx', terminate, desc = 'dap: terminate' },
    { '<localleader>dt', repl_toggle, desc = 'dap REPL: toggle' },
    { '<localleader>da', attach, desc = 'dap(node): attach' },
    { '<localleader>dA', attach_to_remote, desc = 'dap(node): attach to remote' },
  },
  config = function()
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
  end,
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
      keys = {
        {
          '<localleader>du',
          function() require('dapui').toggle({ reset = true }) end,
          desc = 'dap-ui: toggle',
        },
      },
      config = function()
        require('dapui').setup({
          windows = { indent = 2 },
          floating = { border = rvim.ui.current.border },
        })
        local dap = require('dap')
        dap.listeners.after.event_initialized['dapui_config'] = function()
          require('dapui').open()
          vim.api.nvim_exec_autocmds('User', { pattern = 'DapStarted' })
        end
        dap.listeners.before.event_terminated['dapui_config'] = function() require('dapui').close() end
        dap.listeners.before.event_exited['dapui_config'] = function() require('dapui').close() end
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
