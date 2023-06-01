rvim.debugger = { layout = { ft = { dart = 2 } } }

local function set_breakpoint() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end
local function log_breakpoint() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end

return {
  {
    'mfussenegger/nvim-dap',
    keys = {
      { '<localleader>db', function() require('dap').toggle_breakpoint() end, desc = 'dap: toggle breakpoint' },
      { '<localleader>dB', set_breakpoint, desc = 'dap: set conditional breakpoint' },
      { '<localleader>dc', function() require('dap').continue() end, desc = 'dap: continue or start debugging' },
      { '<localleader>dC', function() require('dap').clear_breakpoints() end, desc = 'dap: clear breakpoint' },
      { '<localleader>de', function() require('dap').step_out() end, desc = 'dap: step out' },
      { '<localleader>dh', function() require('dap').step_back() end, desc = 'dap: step back' },
      { '<localleader>di', function() require('dap').step_into() end, desc = 'dap: step into' },
      { '<localleader>dl', function() require('dap').run_last() end, desc = 'dap REPL: run last' },
      { '<localleader>dL', log_breakpoint, desc = 'dap: log breakpoint' },
      { '<localleader>do', function() require('dap').step_over() end, desc = 'dap: step over' },
      { '<localleader>dr', function() require('dap').restart() end, desc = 'dap: restart' },
      { '<localleader>dt', function() require('dap').repl.toggle() end, desc = 'dap: toggle repl' },
      { '<localleader>dw', function() require('dap.ui.widgets').hover() end, desc = 'dap: hover' },
      { '<localleader>dx', function() require('dap').terminate() end, desc = 'dap: terminate' },
      {
        '<localleader>du',
        function() require('dapui').toggle({ reset = true }) end,
        desc = 'dap-ui: toggle',
      },
    },
    config = function()
      local fn, ui = vim.fn, rvim.ui
      local dap = require('dap')

      -- DON'T automatically stop at exceptions
      dap.defaults.fallback.exception_breakpoints = {}

      fn.sign_define('DapBreakpoint', {
        text = ui.codicons.misc.bug,
        texthl = 'DapBreakpoint',
        linehl = '',
        numhl = '',
      })

      fn.sign_define('DapBreakpointRejected', {
        text = ui.codicons.misc.bug,
        texthl = 'DapBreakpointRejected',
        linehl = '',
        numhl = '',
      })

      fn.sign_define('DapStopped', {
        text = ui.icons.misc.dap_green,
        texthl = 'DapStopped',
        linehl = '',
        numhl = '',
      })

      local ui_ok, dapui = pcall(require, 'dapui')
      if not ui_ok then return end
      dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open(rvim.debugger.layout.ft[vim.bo.ft]) end
      dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
      dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
    end,
    dependencies = {
      {
        'rcarriga/nvim-dap-ui',
        opts = {
          windows = { indent = 2 },
          floating = { border = rvim.ui.current.border },
        },
      },
      { 'theHamsta/nvim-dap-virtual-text', opts = { all_frames = true } },
    },
  },
  {
    'mxsdev/nvim-dap-vscode-js',
    ft = { 'typescriptreact', 'typescript', 'javascript', 'javascriptreact' },
    opts = {
      node_path = 'node',
      debugger_cmd = { 'js-debug-adapter' },
      adapters = { 'chrome', 'pwa-node', 'pwa-chrome', 'node-terminal', 'pwa-extensionHost' },
    },
    config = function(_, opts)
      require('dap-vscode-js').setup(opts)
      for _, language in ipairs({ 'typescript', 'typescriptreact', 'javascript' }) do
        require('dap').configurations[language] = {
          {
            type = 'chrome',
            request = 'launch',
            name = 'Launch Chrome against localhost',
            url = 'http://localhost:3000',
            webRoot = '${workspaceFolder}',
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach Program (pwa-node, select pid)',
            cwd = '${workspaceFolder}',
            processId = require('dap.utils').pick_process,
            skipFiles = { '<node_internals>/**' },
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch Current File (pwa-node)',
            cwd = vim.fn.getcwd(),
            args = { '${file}' },
            sourceMaps = true,
            protocol = 'inspector',
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch Current File (pwa-node with ts-node)',
            cwd = vim.fn.getcwd(),
            runtimeArgs = { '--loader', 'ts-node/esm' },
            runtimeExecutable = 'node',
            args = { '${file}' },
            sourceMaps = true,
            protocol = 'inspector',
            skipFiles = { '<node_internals>/**', 'node_modules/**' },
            resolveSourceMapLocations = {
              '${workspaceFolder}/**',
              '!**/node_modules/**',
            },
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch Current File (pwa-node with deno)',
            cwd = vim.fn.getcwd(),
            runtimeArgs = { 'run', '--inspect-brk', '--allow-all', '${file}' },
            runtimeExecutable = 'deno',
            attachSimplePort = 9229,
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch Test Current File (pwa-node with jest)',
            cwd = vim.fn.getcwd(),
            runtimeArgs = { '${workspaceFolder}/node_modules/.bin/jest' },
            runtimeExecutable = 'node',
            args = { '${file}', '--coverage', 'false' },
            rootPath = '${workspaceFolder}',
            sourceMaps = true,
            console = 'integratedTerminal',
            internalConsoleOptions = 'neverOpen',
            skipFiles = { '<node_internals>/**', 'node_modules/**' },
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch Test Current File (pwa-node with vitest)',
            cwd = vim.fn.getcwd(),
            program = '${workspaceFolder}/node_modules/vitest/vitest.mjs',
            args = { '--inspect-brk', '--threads', 'false', 'run', '${file}' },
            autoAttachChildProcesses = true,
            smartStep = true,
            console = 'integratedTerminal',
            skipFiles = { '<node_internals>/**', 'node_modules/**' },
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch Test Current File (pwa-node with deno)',
            cwd = vim.fn.getcwd(),
            runtimeArgs = { 'test', '--inspect-brk', '--allow-all', '${file}' },
            runtimeExecutable = 'deno',
            attachSimplePort = 9229,
          },
          {
            type = 'pwa-chrome',
            request = 'attach',
            name = 'Attach Program (pwa-chrome, select port)',
            program = '${file}',
            cwd = vim.fn.getcwd(),
            sourceMaps = true,
            port = function() return vim.fn.input('Select port: ', 9222) end,
            webRoot = '${workspaceFolder}',
          },
        }
      end
    end,
  },
}
