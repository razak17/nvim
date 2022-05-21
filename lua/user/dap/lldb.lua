local dap = require("dap")
local M = {}

function M.setup()
  dap.adapters.lldb = {
    type = "executable",
    command = rvim.paths.vscode_lldb .. "/adapter/codelldb",
    name = "lldb",
  }

  -- CPP
  dap.configurations.cpp = {
    {
      name = "Launch",
      type = "lldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
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
