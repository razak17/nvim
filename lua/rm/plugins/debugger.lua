local input = vim.fn.input

rvim.debugger = { layout = { ft = { dart = 2 } } }

return {
  {
    'mfussenegger/nvim-dap',
    enabled = not rvim.plugins.minimal,
    keys = {
      {
        '<localleader>dbp',
        -- function() require('dap').toggle_breakpoint() end,
        function() require('persistent-breakpoints.api').toggle_breakpoint() end,
        desc = 'dap: toggle breakpoint',
      },
      {
        '<localleader>dbc',
        -- function() require('dap').set_breakpoint(input('Breakpoint condition: ')) end,
        function() require('persistent-breakpoints.api').set_breakpoint('Breakpoint condition: ') end,
        desc = 'dap: set conditional breakpoint',
      },
      {
        '<localleader>dbm',
        function() require('dap').set_breakpoint(nil, nil, input('Log point message: ')) end,
        desc = 'dap: log breakpoint',
      },
      {
        '<localleader>dbx',
        -- function() require('dap').clear_breakpoints() end,
        function() require('persistent-breakpoints.api').clear_all_breakpoints() end,
        desc = 'dap: clear breakpoint',
      },
      {
        '<localleader>dc',
        function() require('dap').continue() end,
        desc = 'dap: continue or start debugging',
      },
      { '<localleader>dh', function() require('dap').step_back() end, desc = 'dap: step back' },
      { '<localleader>di', function() require('dap').step_into() end, desc = 'dap: step into' },
      { '<localleader>do', function() require('dap').step_over() end, desc = 'dap: step over' },
      { '<localleader>dO', function() require('dap').step_out() end, desc = 'dap: step out' },
      { '<localleader>dr', function() require('dap').repl.toggle() end, desc = 'dap: toggle repl' },
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

      fn.sign_define('DapBreakpointCondition', {
        text = '󰙧',
        texthl = 'DapStopped',
        linehl = '',
        numhl = '',
      })

      fn.sign_define('DapLogPoint', {
        text = '󰃷',
        texthl = 'DapStopped',
        linehl = '',
        numhl = '',
      })

      local ui_ok, dapui = pcall(require, 'dapui')
      if not ui_ok then return end
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open(rvim.debugger.layout.ft[vim.bo.ft])
      end
      dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
      dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end

      local mason_registry = require('mason-registry')
      local js_debug = mason_registry.get_package('js-debug-adapter')
      local debug_server_path = js_debug:get_install_path() .. '/js-debug/src/dapDebugServer.js'

      require('dap').adapters['pwa-node'] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          args = { debug_server_path, '${port}' },
        },
      }

      for _, language in ipairs({ 'typescript', 'typescriptreact', 'javascript', 'svelte' }) do
        require('dap').configurations[language] = {
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch current file (pwa-node)',
            program = '${file}',
            cwd = '${workspaceFolder}',
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach program (pwa-node, select pid)',
            cwd = '${workspaceFolder}/src',
            processId = require('dap.utils').pick_process,
            sourceMaps = true,
            resolveSourceMapLocations = { '${workspaceFolder}/**', '!**/node_modules/**' },
            skipFiles = { '<node_internals>/**', '${workspaceFolder}/node_modules/**/*.js' },
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch current file (pwa-node with ts-node)',
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
            name = 'Launch current file (pwa-node with deno)',
            runtimeExecutable = 'deno',
            runtimeArgs = {
              'run',
              '--inspect-wait',
              '--allow-all',
            },
            program = '${file}',
            cwd = '${workspaceFolder}',
            attachSimplePort = 9229,
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch test current file (pwa-node with jest)',
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
            name = 'Launch test current file (pwa-node with vitest)',
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
            name = 'Launch test current file (pwa-node with deno)',
            cwd = vim.fn.getcwd(),
            runtimeArgs = { 'test', '--inspect-brk', '--allow-all', '${file}' },
            runtimeExecutable = 'deno',
            attachSimplePort = 9229,
          },
          {
            type = 'pwa-chrome',
            name = 'Launch Chrome to debug client',
            request = 'launch',
            url = 'http://localhost:5173',
            sourceMaps = true,
            protocol = 'inspector',
            port = 9222,
            webRoot = '${workspaceFolder}/src',
            -- skip files from vite's hmr
            skipFiles = { '**/node_modules/**/*', '**/@vite/*', '**/src/client/*', '**/src/*' },
          },
        }
      end
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
      {
        'Weissle/persistent-breakpoints.nvim',
        opts = { load_breakpoints_event = { 'BufReadPost' } },
      },
    },
  },
}
