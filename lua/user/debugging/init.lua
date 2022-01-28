local M = {}

local dap = require "dap"

rvim.dap = {
  install_dir = rvim.get_cache_dir() .. "dap",
  python_dir = rvim.get_cache_dir() .. "dap/python_dbg/bin/python",
  node_dir = rvim.get_cache_dir() .. "dap/jsnode_dbg/vscode-node-debug2/out/src/nodeDebug.js",
  breakpoint = {
    text = "",
    texthl = "LspDiagnosticsSignError",
    linehl = "",
    numhl = "",
  },
  breakpoint_rejected = {
    text = "",
    texthl = "LspDiagnosticsSignHint",
    linehl = "",
    numhl = "",
  },
  stopped = {
    text = "",
    texthl = "LspDiagnosticsSignInformation",
    linehl = "DiagnosticUnderlineInfo",
    numhl = "LspDiagnosticsSignInformation",
  },
}

-- vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })
-- vim.fn.sign_define("DapStopped", { text = "🟢", texthl = "", linehl = "", numhl = "" })

vim.fn.sign_define("DapBreakpoint", rvim.dap.breakpoint)
vim.fn.sign_define("DapBreakpointRejected", rvim.dap.breakpoint_rejected)
vim.fn.sign_define("DapStopped", rvim.dap.stopped)

dap.defaults.fallback.terminal_win_cmd = "50vsplit new"

function M.setup()
  local configurations = require "user.debugging.configurations"

  -- Lua
  dap.configurations.lua = configurations.lua
  dap.adapters.nlua = function(callback, config)
    callback { type = "server", host = config.host, port = config.port }
  end

  -- JavaScript / Node
  dap.configurations.javascript = configurations.javascript
  dap.adapters.node2 = { type = "executable", command = "node", args = { rvim.dap.node_dir } }

  -- Python
  dap.configurations.python = configurations.python
  dap.adapters.python = {
    type = "executable",
    command = rvim.dap.python_dir,
    args = { "-m", "debugpy.adapter" },
  }

  -- CPP
  dap.configurations.cpp = configurations.cpp
  dap.adapters.lldb = { type = "executable", command = "/usr/bin/lldb-vscode", name = "lldb" }

  -- C
  dap.configurations.c = dap.configurations.cpp

  -- Rust
  dap.configurations.rust = dap.configurations.cpp

  rvim.augroup("DapBehavior", {
    {
      events = { "FileType" },
      targets = { "dapui_scopes", "dapui_breakpoints", "dapui_stacks", "dapui_watches" },
      command = "set laststatus=0",
    },
  })
end

return M
