local fn, ui = vim.fn, rvim.ui
local input = vim.fn.input
local codicons = ui.codicons

rvim.debugger = {
  layout = { ft = { dart = 2 } },
  icons = {
    Breakpoint = { codicons.misc.bug, 'DapBreakpoint' }, -- 
    BreakpointRejected = { codicons.misc.bug, 'DapBreakpointRejected' },
    Stopped = { ui.icons.misc.dap_green, 'DapStopped' }, -- 󰁕
    BreakpointCondition = { ' ', 'DiagnosticError' },
    LogPoint = { '󰃷', 'DiagnosticInfo' },
  },
}

return {
  {
    'mfussenegger/nvim-dap',
    cond = not rvim.plugins.minimal,
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
        function()
          require('persistent-breakpoints.api').set_breakpoint(
            'Breakpoint condition: '
          )
        end,
        desc = 'dap: set conditional breakpoint',
      },
      {
        '<localleader>dbm',
        function()
          require('dap').set_breakpoint(nil, nil, input('Log point message: '))
        end,
        desc = 'dap: log breakpoint',
      },
      {
        '<localleader>dbx',
        -- function() require('dap').clear_breakpoints() end,
        function()
          require('persistent-breakpoints.api').clear_all_breakpoints()
        end,
        desc = 'dap: clear breakpoint',
      },
      {
        '<localleader>dc',
        function() require('dap').continue() end,
        desc = 'dap: continue or start debugging',
      },
      {
        '<localleader>dh',
        function() require('dap').step_back() end,
        desc = 'dap: step back',
      },
      {
        '<localleader>di',
        function() require('dap').step_into() end,
        desc = 'dap: step into',
      },
      {
        '<localleader>do',
        function() require('dap').step_over() end,
        desc = 'dap: step over',
      },
      {
        '<localleader>dO',
        function() require('dap').step_out() end,
        desc = 'dap: step out',
      },
      {
        '<localleader>drc',
        function() require('dap').run_to_cursor() end,
        desc = 'dap: run to cursor',
      },
      {
        '<localleader>drl',
        function() require('dap').run_last() end,
        desc = 'dap: run last',
      },
      {
        '<localleader>drr',
        function() require('dap').repl.toggle() end,
        desc = 'dap: toggle repl',
      },
      {
        '<localleader>drs',
        function() require('dap').restart() end,
        desc = 'dap: restart',
      },
      {
        '<localleader>ds',
        function()
          local widgets = require('dap.ui.widgets')
          widgets.centered_float(widgets.scopes, { border = 'rounded' })
        end,
        desc = 'DAP Scopes',
      },
      {
        '<localleader>dw',
        function() require('dap.ui.widgets').hover() end,
        desc = 'dap: hover',
      },
      {
        '<localleader>dx',
        function() require('dap').terminate() end,
        desc = 'dap: terminate',
      },
      {
        '<localleader>du',
        function() require('dapui').toggle({ reset = true }) end,
        desc = 'dap-ui: toggle',
      },
    },
    config = function()
      local dap = require('dap')

      -- DON'T automatically stop at exceptions
      dap.defaults.fallback.exception_breakpoints = {}

      for name, sign in pairs(rvim.debugger.icons) do
        fn.sign_define('Dap' .. name, {
          text = sign[1],
          texthl = sign[2],
        linehl = '',
        numhl = '',
      })
      end

      local vscode = require('dap.ext.vscode')
      local _filetypes = require('mason-nvim-dap.mappings.filetypes')
      -- stylua: ignore
      local filetypes = vim.tbl_deep_extend("force", _filetypes, {
        ["node"] = { "javascriptreact", "typescriptreact", "typescript", "javascript" },
        ["pwa-node"] = { "javascriptreact", "typescriptreact", "typescript", "javascript" },
      })

      vim.schedule(function()
        vscode.json_decode = require('overseer.json').decode
        vscode.load_launchjs(nil, filetypes)
      end)

      dap.adapters.nlua = function(callback, config)
        callback({
          type = 'server',
          host = config.host or '127.0.0.1',
          port = config.port or 8086,
        })
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

      local js_debug = require('mason-registry').get_package('js-debug-adapter')
      local debug_server_path = js_debug:get_install_path()
        .. '/js-debug/src/dapDebugServer.js'

      require('dap').adapters['pwa-node'] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          args = { debug_server_path, '${port}' },
        },
      }

      for _, language in ipairs({
        'typescript',
        'typescriptreact',
        'javascript',
        'svelte',
      }) do
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
            resolveSourceMapLocations = {
              '${workspaceFolder}/**',
              '!**/node_modules/**',
            },
            skipFiles = {
              '<node_internals>/**',
              '${workspaceFolder}/node_modules/**/*.js',
            },
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
            runtimeArgs = {
              -- '${workspaceFolder}/node_modules/.bin/jest',
              './node_modules/jest/bin/jest.js',
              '--runInBand',
            },
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
            skipFiles = {
              '**/node_modules/**/*',
              '**/@vite/*',
              '**/src/client/*',
              '**/src/*',
            },
          },
          -- Debug web applications (client side)
          {
            type = 'pwa-chrome',
            name = 'Launch & Debug Chrome',
            request = 'launch',
            url = function()
              local co = coroutine.running()
              return coroutine.create(function()
                vim.ui.input(
                  { prompt = 'Enter URL: ', default = 'http://localhost:3000' },
                  function(url)
                    if url == nil or url == '' then
                      return
                    else
                      coroutine.resume(co, url)
                    end
                  end
                )
              end)
            end,
            sourceMaps = true,
            protocol = 'inspector',
            webRoot = vim.fn.getcwd(),
            userDataDir = false,
          },
        }
      end
    end,
    dependencies = {
      'nvim-neotest/nvim-nio',
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
  {
    'jay-babu/mason-nvim-dap.nvim',
    dependencies = 'mason.nvim',
    cmd = { 'DapInstall', 'DapUninstall' },
    opts = {},
  },
}
