local icons = rvim.style.icons

local M = {}

rvim.dap = {
  python_dir = rvim.paths.mason .. '/packages/debugpy/venv/bin/python',
  node_dir = rvim.paths.mason .. '/packages/node-debug2-adapter/out/src/nodeDebug.js',
  lldb_dir = rvim.paths.vscode_lldb .. '/adapter/codelldb',
  breakpoint = {
    text = icons.misc.bug_alt,
    texthl = 'DapBreakpoint',
    linehl = '',
    numhl = '',
  },
  breakpoint_rejected = {
    text = icons.misc.bug_alt,
    texthl = 'DapBreakpointRejected',
    linehl = '',
    numhl = '',
  },
  stopped = {
    text = icons.misc.dap_hollow,
    texthl = 'DapStopped',
    linehl = '',
    numhl = '',
  },
}

function M.setup()
  local dap = require('dap')
  local P = require('zephyr.palette')
  local utils = require("user.utils")
  local is_directory = utils.is_directory
  local fn = vim.fn

  fn.sign_define('DapBreakpoint', rvim.dap.breakpoint)
  fn.sign_define('DapBreakpointRejected', rvim.dap.breakpoint_rejected)
  fn.sign_define('DapStopped', rvim.dap.stopped)

  require('user.utils.highlights').plugin('dap', {
    DapBreakpoint = { foreground = P.error_red },
    DapBreakpointRejected = { foreground = P.dark_orange },
    DapStopped = { foreground = P.dark_green },
  })

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
        local cwd = fn.getcwd()
        if is_directory(cwd .. '/venv/bin/python') then
          return cwd .. '/venv/bin/python'
        elseif is_directory(cwd .. '/.venv/bin/python') then
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
      cwd = fn.getcwd(),
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
  -- lldb
  dap.adapters.lldb = {
    type = 'executable',
    command = rvim.dap.lldb_dir,
    name = 'lldb',
  }
  -- CPP
  dap.configurations.cpp = {
    {
      name = 'Launch',
      type = 'lldb',
      request = 'launch',
      program = function() return fn.input('Path to executable: ', fn.getcwd() .. '/', 'file') end,
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
