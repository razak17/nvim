local fn, ui = vim.fn, ar.ui
local input = vim.fn.input
local codicons = ui.codicons
local minimal = ar.plugins.minimal

-- Config inspired from https://github.com/nikolovlazar/dotfiles/blob/main/.config/nvim/lua/plugins/dap.lua
-- and Lazyvim's https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/dap/core.lua
-- For further explanation, see https://www.youtube.com/watch?v=Ul_WPhS2bis

-- stylua: ignore
local js_based_languages = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue', 'svelte' }

---@param config {args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == 'function' and (config.args() or {})
    or config.args
    or {}
  config = vim.deepcopy(config)

  ---@cast args string[]
  config.args = function()
    ---@diagnostic disable-next-line: redundant-parameter
    local new_args = fn.input('Run with args: ', table.concat(args, ' ')) --[[@as string]]
    return vim.split(fn.expand(new_args) --[[@as string]], ' ')
  end

  return config
end

ar.debugger = {
  layout = { ft = { dart = 2 } },
  icons = {
    Breakpoint = { codicons.misc.bug, 'DapBreakpoint' }, -- 
    BreakpointRejected = { codicons.misc.bug, 'DapBreakpointRejected' },
    Stopped = { ui.icons.misc.dap_green, 'DapStopped' }, -- 󰁕
    BreakpointCondition = { ' ', 'DiagnosticError' },
    LogPoint = { '󰃷', 'DiagnosticInfo' },
  },
  filetypes = {
    ['chrome'] = js_based_languages,
    ['node'] = js_based_languages,
    ['pwa-node'] = js_based_languages,
    ['pwa-chrome'] = js_based_languages,
    ['node-terminal'] = js_based_languages,
  },
}

---@param source string
---@param opts? table | string
---@return function
local function d(source, opts)
  return function() require('dap')[source](opts) end
end

---@param source string
---@return function
local function pbp(source, opts)
  opts = opts or {}
  return function() require('persistent-breakpoints.api')[source](opts) end
end

return {
  {
    'mfussenegger/nvim-dap',
    cond = not minimal,
    init = function()
      vim.g.whichkey_add_spec({
        { '<localleader>d', group = 'Dap' },
        { '<localleader>db', group = 'Breakpoint' },
        { '<localleader>dr', group = 'Run' },
      })
    end,
    -- stylua: ignore
    keys = {
      {'<localleader>da', function() d('continue',{ before = get_args}) end, desc = 'dap: run with args' },
      { '<localleader>dbp', d('toggle_breakpoint'), desc = 'dap: toggle breakpoint' },
      {
        '<localleader>dbc',
        function() require('dap').set_breakpoint(input('Breakpoint condition: ')) end,
        desc = 'dap: set conditional breakpoint',
      },
      { '<localleader>dbx', d('clear_breakpoints'), desc = 'dap: clear breakpoint' },
      { '<localleader>dbm', function() require('dap').set_breakpoint(nil, nil, input('Log point message: ')) end, desc = 'dap: log breakpoint', },
      { '<localleader>dc', d('continue'), desc = 'dap: continue or start debugging' },
      { '<localleader>dh', d('step_back'), desc = 'dap: step back' },
      { '<localleader>di', d('step_into'), desc = 'dap: step into' },
      { '<localleader>do', d('step_over'), desc = 'dap: step over' },
      { '<localleader>dO', d('step_out'), desc = 'dap: step out' },
      { '<localleader>drc', d('run_to_cursor'), desc = 'dap: run to cursor' },
      { '<localleader>drl', d('run_last'), desc = 'dap: run last' },
      { '<localleader>drr', function() require('dap').repl.toggle() end, desc = 'dap: toggle repl' },
      { '<localleader>drs', d('restart'), desc = 'dap: restart' },
      { '<localleader>dx', d('terminate'), desc = 'dap: terminate' },
      {
        '<localleader>ds',
        function()
          local widgets = require('dap.ui.widgets')
          widgets.centered_float(widgets.scopes, { border = 'rounded' })
        end,
        desc = 'dap-ui: scopes',
      },
      { '<localleader>dw', function() require('dap.ui.widgets').hover() end, desc = 'dap: hover' },
    },
    config = function()
      local dap = require('dap')

      -- DON'T automatically stop at exceptions
      dap.defaults.fallback.exception_breakpoints = {}

      for name, sign in pairs(ar.debugger.icons) do
        fn.sign_define('Dap' .. name, {
          text = sign[1],
          texthl = sign[2],
          linehl = '',
          numhl = '',
        })
      end

      -- setup dap config by VsCode launch.json file
      local dap_vscode = require('dap.ext.vscode')
      local json = require('plenary.json')
      ---@diagnostic disable-next-line: duplicate-set-field
      dap_vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str, {}))
      end
      local _filetypes = require('mason-nvim-dap.mappings.filetypes')
      local filetypes =
        vim.tbl_deep_extend('force', _filetypes, ar.debugger.filetypes)
      dap_vscode.type_to_filetypes = filetypes

      -- Lua configurations.
      -- 1. Open a Neovim instance (instance A)
      -- 2. Launch the DAP server with (A) >
      --    :lua require"osv".launch({port=8086})
      -- 3. Open another Neovim instance (instance B)
      -- 4. Open `myscript.lua` (B)
      -- 5. Place a breakpoint on line 2 using (B) >
      --    :lua require"dap".toggle_breakpoint()
      -- 6. Connect the DAP client using (B) >
      --    :lua require"dap".continue()
      -- 7. Run `myscript.lua` in the other instance (A) >
      --    :luafile myscript.lua
      -- 8. The breakpoint should hit and freeze the instance

      --@param callback fun(adapter:table)
      ---@param config table
      dap.adapters.nlua = function(callback, config)
        local adapter = {
          type = 'server',
          host = config.host or '127.0.0.1',
          port = config.port or 8086,
        }
        if config.start_neovim then
          local dap_run = dap.run
          ---@diagnostic disable-next-line: duplicate-set-field
          dap.run = function(c)
            adapter.port = c.port
            adapter.host = c.host
          end
          require('osv').run_this()
          dap.run = dap_run
        end
        callback(adapter)
      end

      dap.configurations.lua = {
        {
          type = 'nlua',
          request = 'attach',
          name = 'Run this file',
          start_neovim = {},
        },
        {
          type = 'nlua',
          request = 'attach',
          name = 'Attach to running Neovim instance',
          host = function()
            local value = fn.input('Host (127.0.0.1): ')
            return value ~= '' and value or '127.0.0.1'
          end,
          port = function()
            local val = tonumber(fn.input('Port (8086): '))
            return val and val > 0 and val or 8086
          end,
        },
      }

      for _, adapter in pairs({ 'node', 'chrome' }) do
        local pwa_adapter = 'pwa-' .. adapter
        -- Handle launch.json configurations
        -- which specify type as "node" or "chrome"
        -- Inspired by https://github.com/StevanFreeborn/nvim-config/blob/main/lua/plugins/debugging.lua#L111-L123
        dap.adapters[pwa_adapter] = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = {
            command = 'node',
            args = {
              ar.get_pkg_path(
                'js-debug-adapter',
                'js-debug/src/dapDebugServer.js'
              ),
              '${port}',
            },
          },
          enrich_config = function(config, on_config)
            -- Under the hood, always use the main adapter
            config.type = pwa_adapter
            on_config(config)
          end,
        }
        dap.adapters[adapter] = dap.adapters[pwa_adapter]
      end

      for _, language in ipairs(js_based_languages) do
        dap.configurations[language] = {
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch current file (pwa-node)',
            program = '${file}',
            cwd = '${workspaceFolder}',
            sourceMaps = true,
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
            cwd = fn.getcwd(),
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
            cwd = fn.getcwd(),
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
            cwd = fn.getcwd(),
            program = '${workspaceFolder}/node_modules/vitest/vitest.mjs',
            args = { 'run', '${file}' },
            autoAttachChildProcesses = true,
            smartStep = true,
            skipFiles = { '<node_internals>/**', 'node_modules/**' },
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch test current file (pwa-node with vitest)',
            cwd = fn.getcwd(),
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
            cwd = fn.getcwd(),
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
            webRoot = fn.getcwd(),
            userDataDir = false,
            resolveSourceMapLocations = {
              '${workspaceFolder}/**',
              '!**/node_modules/**',
            },

            -- From https://github.com/lukas-reineke/dotfiles/blob/master/vim/lua/plugins/dap.lua
            -- To test how it behaves
            rootPath = '${workspaceFolder}',
            cwd = '${workspaceFolder}',
            console = 'integratedTerminal',
            internalConsoleOptions = 'neverOpen',
            sourceMapPathOverrides = {
              ['./*'] = '${workspaceFolder}/src/*',
            },
          },
          -- Divider for the launch.json derived configs
          {
            name = '----- ↓ launch.json configs (if available) ↓ -----',
            type = '',
            request = 'launch',
          },
        }
      end
    end,
    dependencies = {
      'nvim-neotest/nvim-nio',
      {
        'jbyuki/one-small-step-for-vimkind',
        keys = {
          {
            '<leader>dL',
            function() require('osv').launch({ port = 8086 }) end,
            desc = 'osv: launch adapter',
          },
          {
            '<leader>dT',
            function() require('osv').run_this() end,
            desc = 'osv: lua adapter (run this)',
          },
        },
      },
      {
        'rcarriga/nvim-dap-ui',
        -- stylua: ignore
        keys = {
          { '<localleader>d?', function() require('dapui').eval(nil, { enter = true }) end, desc = 'dap-ui: eval' },
          { '<localleader>du', function() require('dapui').toggle({ reset = true }) end, desc = 'dap-ui: toggle' },
        },
        opts = {
          windows = { indent = 2 },
          layouts = {
            {
              elements = { 'scopes', 'breakpoints', 'stacks', 'watches' },
              size = 60,
              position = 'left',
            },
            {
              elements = { 'repl', 'console' },
              size = 0.25,
              position = 'bottom',
            },
          },
          floating = { border = ar.ui.current.border },
        },
        config = function(_, opts)
          local dap = require('dap')
          local dapui = require('dapui')
          dapui.setup(opts)
          local l = dap.listeners
          l.after.event_initialized['dapui_config'] = function() dapui.open() end
          l.before.event_exited['dapui_config'] = function() dapui.close() end
          l.before.event_terminated['dapui_config'] = function() dapui.close() end
        end,
      },
      { 'theHamsta/nvim-dap-virtual-text', opts = { all_frames = true } },
      {
        'Weissle/persistent-breakpoints.nvim',
        event = { 'BufReadPost' },
        cond = false,
        -- stylua: ignore
        keys = {
          { '<localleader>dbp', pbp('toggle_breakpoint'), desc = 'dap: toggle breakpoint', },
          {
            '<localleader>dbc',
            function() require('persistent-breakpoints.api').set_conditional_breakpoint( 'Breakpoint condition: ') end,
            desc = 'dap: set conditional breakpoint',
          },
          { '<localleader>dbx', pbp('clear_all_breakpoints'), desc = 'dap: clear breakpoint', },
        },
        opts = { load_breakpoints_event = { 'BufReadPost' } },
      },
    },
  },
  {
    'jay-babu/mason-nvim-dap.nvim',
    cond = not minimal,
    dependencies = 'mason.nvim',
    cmd = { 'DapInstall', 'DapUninstall' },
    opts = {},
  },
}
