local M = {}

function M.setup()
  local dap = require('dap')
  local fn = vim.fn

  local function repl_toggle()
    require('dap').repl.toggle(nil, 'botright split')
  end
  local function continue()
    require('dap').continue()
  end
  local function step_out()
    require('dap').step_out()
  end
  local function step_into()
    require('dap').step_into()
  end
  local function step_over()
    require('dap').step_over()
  end
  local function step_back()
    require('dap').step_back()
  end
  local function run_last()
    require('dap').run_last()
  end
  local function toggle_breakpoint()
    require('dap').toggle_breakpoint()
  end
  local function set_breakpoint()
    require('dap').set_breakpoint(fn.input('Breakpoint condition: '))
  end

  -- utils

  local function attach()
    print('attaching')
    dap.run({
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
    dap.run({
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

  require('which-key').register({
    ['<leader>d'] = {
      name = '+Debug',
      a = { attach, 'attach' },
      A = { attach_to_remote, 'attach remote' },

      h = { step_back, 'dap: step over' },
      i = { step_into, 'dap: step into' },
      o = { step_over, 'dap: step over' },
      u = { step_out, 'dap: step out' },

      b = { toggle_breakpoint, 'dap: toggle breakpoint' },
      B = { set_breakpoint, 'dap: set breakpoint' },
      c = { continue, 'dap: continue or start debugging' },
      l = { run_last, 'dap REPL: run last' },
      t = { repl_toggle, 'dap REPL: toggle' },

      -- ["?"] = {
      --   ':lua local widgets=require"dap.ui.widgets";widgets.centered_float(widgets.scopes)<CR>',
      --   "scopes",
      -- },
      -- C = { ":lua require'dap'.clear_breakpoints()<cr>", "clear breakpoints" },
      -- e = { ":lua require'dap'.set_exception_breakpoints({'all'})<cr>", "breakpoint exception" },
      -- n = { ":lua require'dap'.run_to_cursor()<cr>", "run to cursor" },
      -- K = { ":lua require'dap.ui.widgets'.hover()<cr>", "hover" },
      -- R = { ':lua require"dap".repl.open({}, "vsplit")<cr><C-w>l<cr>', "open repl in vsplit" },
      -- x = { ":lua require'dap'.disconnect()<cr>", "disconnect" },
      -- z = { ":lua require'dap'.terminate()<cr>", "terminate" },
      -- g = { ":lua require'dap'.session()<cr>", "get session" },
      -- q = { ":lua require'dap'.close()<cr>", "quit" },
      -- k = { ":lua require'dap'.up()<cr>", "up" },
      -- j = { ":lua require'dap'.down()<cr>", "down" },
      -- p = { ":lua require'dap'.pause.toggle()<cr>", "pause" },
      -- f = { ":Telescope dap frames<cr>", "frames" },
      -- v = { ":Telescope dap variables<cr>", "variables" },
      -- b = { ":Telescope dap list_breakpoints<cr>", "list breakpoints" },
    },
  })
end

function M.config()
  local dap = require('dap')
  local icons = rvim.style.icons

  rvim.dap = {
    python_dir = rvim.get_cache_dir() .. '/dap/python/bin/python',
    node_dir = rvim.get_cache_dir() .. '/dap/jsnode/vscode-node-debug2/out/src/nodeDebug.js',
    breakpoint = {
      text = icons.misc.bug_alt,
      texthl = 'LspDiagnosticsSignError',
      linehl = '',
      numhl = '',
    },
    breakpoint_rejected = {
      text = icons.misc.bug_alt,
      texthl = 'LspDiagnosticsSignHint',
      linehl = '',
      numhl = '',
    },
    stopped = {
      text = icons.misc.dap_hollow,
      texthl = 'LspDiagnosticsSignInformation',
      linehl = 'DiagnosticUnderlineInfo',
      numhl = 'LspDiagnosticsSignInformation',
    },
  }

  vim.fn.sign_define('DapBreakpoint', rvim.dap.breakpoint)
  vim.fn.sign_define('DapBreakpointRejected', rvim.dap.breakpoint_rejected)
  vim.fn.sign_define('DapStopped', rvim.dap.stopped)

  dap.defaults.fallback.terminal_win_cmd = '50vsplit new'

  -- DON'T automatically stop at exceptions
  dap.defaults.fallback.exception_breakpoints = {}
  -- python
  dap.adapters.python = {
    type = 'executable',
    command = rvim.dap.python_dir,
    args = { '-m', 'debugpy.adapter' },
  }
  dap.configurations.python = {
    {
      type = 'python',
      request = 'launch',
      name = 'Launch file',
      program = '${file}',
      pythonPath = function()
        local cwd = vim.fn.getcwd()
        if rvim._exists(cwd .. '/venv/bin/python') then
          return cwd .. '/venv/bin/python'
        elseif rvim._exists(cwd .. '/.venv/bin/python') then
          return cwd .. '/.venv/bin/python'
        else
          return rvim.dap.python_dir
        end
      end,
    },
  }

  -- nodejs
  dap.adapters.node2 = { type = 'executable', command = 'node', args = { rvim.dap.node_dir } }

  dap.configurations.javascript = {
    {
      -- name = "Launch",
      type = 'node2',
      request = 'launch',
      program = '${workspaceFolder}/${file}',
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = 'inspector',
      console = 'integratedTerminal',
    },
  }

  -- nlua
  dap.adapters.nlua = function(callback, config)
    callback({ type = 'server', host = config.host, port = config.port })
  end

  -- Lua
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

  -- lldb
  dap.adapters.lldb = {
    type = 'executable',
    command = rvim.paths.vscode_lldb .. '/adapter/codelldb',
    name = 'lldb',
  }
  -- CPP
  dap.configurations.cpp = {
    {
      name = 'Launch',
      type = 'lldb',
      request = 'launch',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
      runInTerminal = true,
    },
  }
  -- C
  dap.configurations.c = dap.configurations.cpp
  -- Rust
  dap.configurations.rust = dap.configurations.cpp
end

return M
