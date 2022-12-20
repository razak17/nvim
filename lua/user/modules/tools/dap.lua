return function()
  local fn = vim.fn
  local dap = require('dap')
  local icons = rvim.style.icons

  dap.defaults.fallback.terminal_win_cmd = '50vsplit new'
  -- DON'T automatically stop at exceptions
  dap.defaults.fallback.exception_breakpoints = {}

  -- config
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
  local python_dir = join_paths(rvim.path.mason, 'packages/debugpy/venv/bin/python')
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
        if rvim.executable(cwd .. '/venv/bin/python') then return cwd .. '/venv/bin/python' end
        if rvim.executable(cwd .. '/.venv/bin/python') then return cwd .. '/.venv/bin/python' end
        return python_dir
      end,
    },
  }
  -- go
  dap.adapters.go = {
    type = 'server',
    port = '${port}',
    executable = {
      command = join_paths(rvim.path.mason, 'bin/dlv'),
      args = { 'dap', '-l', '127.0.0.1:${port}' },
    },
  }
  dap.configurations = {
    go = {
      {
        type = 'go', -- Which adapter to use
        name = 'Debug', -- Human readable name
        request = 'launch', -- Whether to "launch" or "attach" to program
        program = '${file}', -- The buffer you are focused on when running nvim-dap
      },
    },
  }
  -- nodejs
  dap.adapters.node2 = {
    type = 'executable',
    command = 'node',
    args = {
      join_paths(rvim.path.mason, 'packages/node-debug2-adapter/out/src/nodeDebug.js'),
    },
  }
  -- javascript
  dap.configurations.javascript = {
    {
      name = 'Launch',
      type = 'node2',
      request = 'launch',
      program = '${workspaceFolder}/${file}',
      cwd = fn.getcwd(),
      sourceMaps = true,
      protocol = 'inspector',
      console = 'integratedTerminal',
    },
    {
      -- For this to work you need to make sure the node process
      -- is started with the `--inspect` flag.
      name = 'Attach to process',
      type = 'node2',
      request = 'attach',
      processId = require('dap.utils').pick_process,
    },
  }
  -- typescript
  dap.configurations.typescript = {
    {
      name = 'ts-node (Node2 with ts-node)',
      type = 'node2',
      request = 'launch',
      cwd = vim.loop.cwd(),
      runtimeArgs = { '-r', 'ts-node/register' },
      runtimeExecutable = 'node',
      args = { '--inspect', '${file}' },
      sourceMaps = true,
      skipFiles = { '<node_internals>/**', 'node_modules/**' },
    },
    {
      name = 'Jest (Node2 with ts-node)',
      type = 'node2',
      request = 'launch',
      cwd = vim.loop.cwd(),
      runtimeArgs = { '--inspect-brk', '${workspaceFolder}/node_modules/.bin/jest' },
      runtimeExecutable = 'node',
      args = { '${file}', '--runInBand', '--coverage', 'false' },
      sourceMaps = true,
      port = 9229,
      skipFiles = { '<node_internals>/**', 'node_modules/**' },
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
        local value = fn.input('Host [127.0.0.1]: ')
        return value ~= '' and value or '127.0.0.1'
      end,
      port = function()
        local val = tonumber(fn.input('Port: '))
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
      command = join_paths(rvim.path.mason, '/bin/codelldb'),
      args = { '--port', '${port}' },
    },
  }
  -- CPP
  dap.configurations.cpp = {
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
  -- C
  dap.configurations.c = dap.configurations.cpp
  -- Rust
  dap.configurations.rust = dap.configurations.cpp
end
