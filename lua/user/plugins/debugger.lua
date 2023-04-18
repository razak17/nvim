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
local function set_breakpoint() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end
local function log_breakpoint() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end

return {
  {
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
      {
        '<localleader>du',
        function() require('dapui').toggle({ reset = true }) end,
        desc = 'dap-ui: toggle',
      },
    },
    config = function()
      local fn, ui = vim.fn, rvim.ui
      local dap = require('dap')
      local ui_ok, dapui = pcall(require, 'dapui')

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

      if not ui_ok then return end
      dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
      dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
      dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open(rvim.debug.layout.ft[vim.bo.ft]) end

      -- python
      local python_dir = join_paths(rvim.path.mason, 'packages', 'debugpy', 'venv', 'bin', 'python')
      dap.adapters.python = {
        type = 'executable',
        command = python_dir,
        args = { '-m', 'debugpy.adapter' },
      }
      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          pythonPath = function()
            local cwd = fn.getcwd()
            if fn.executable(join_paths(cwd, 'venv', 'bin', 'python')) then
              return join_paths(cwd .. 'venv', 'bin', 'python')
            end
            if fn.executable(join_paths(cwd, '.venv', 'bin', 'python')) then
              return join_paths(cwd, '.venv', 'biv', 'python')
            end
            return python_dir
          end,
        },
      }
      -- go
      dap.adapters.go = {
        type = 'server',
        port = '${port}',
        executable = {
          command = join_paths(rvim.path.mason, 'bin', 'dlv'),
          args = { 'dap', '-l', '127.0.0.1:${port}' },
        },
      }
      dap.configurations.go = {
        {
          type = 'go', -- Which adapter to use
          name = 'Debug', -- Human readable name
          request = 'launch', -- Whether to "launch" or "attach" to program
          program = '${file}', -- The buffer you are focused on when running nvim-dap
        },
        {
          type = 'go',
          name = 'Debug test (go.mod)',
          request = 'launch',
          mode = 'test',
          program = './${relativeFileDirname}',
        },
        {
          type = 'go',
          name = 'Attach (Pick Process)',
          mode = 'local',
          request = 'attach',
          processId = require('dap.utils').pick_process,
        },
        {
          type = 'go',
          name = 'Attach (127.0.0.1:9080)',
          mode = 'remote',
          request = 'attach',
          port = '9080',
        },
      }
      -- lua
      dap.adapters.nlua = function(callback, config)
        callback({ type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 })
      end
      dap.configurations.lua = {
        {
          type = 'nlua',
          request = 'attach',
          name = 'Attach to running Neovim instance',
          host = function()
            local value = vim.fn.input('Host [127.0.0.1]: ')
            return value ~= '' and value or '127.0.0.1'
          end,
          port = function()
            local val = tonumber(vim.fn.input('Port: '))
            assert(val, 'Please provide a port number')
            return val
          end,
        },
      }
      -- codelldb
      dap.adapters.codelldb = {
        type = 'server',
        port = '${port}',
        executable = {
          command = join_paths(rvim.path.mason, 'bin', 'codelldb'),
          args = { '--port', '${port}' },
        },
      }
      for _, language in ipairs({ 'c', 'cpp', 'rust' }) do
        require('dap').configurations[language] = {
          {
            name = 'Launch file',
            type = 'codelldb',
            request = 'launch',
            program = function()
              return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
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
          layouts = {
            {
              elements = {
                { id = 'scopes', size = 0.25 },
                { id = 'breakpoints', size = 0.25 },
                { id = 'stacks', size = 0.25 },
                { id = 'watches', size = 0.25 },
              },
              position = 'left',
              size = 20,
            },
            { elements = { { id = 'repl', size = 0.9 } }, position = 'bottom', size = 10 },
          },
        },
      },
      {
        'theHamsta/nvim-dap-virtual-text',
        opts = {
          enabled = true,
          enabled_commands = true,
          highlight_changed_variables = true,
          all_frames = true,
        },
      },
    },
  },
  {
    'mxsdev/nvim-dap-vscode-js',
    ft = { 'typescriptreact', 'typescript', 'javascript', 'javascriptreact' },
    opts = {
      node_path = 'node',
      debugger_path = rvim.path.mason .. '/packages/js-debug-adapter',
      adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
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
