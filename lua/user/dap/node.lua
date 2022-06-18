local dap = require("dap")
local M = {}

function M.setup()
  dap.adapters.node2 = { type = "executable", command = "node", args = { rvim.dap.node_dir } }

  dap.configurations.javascript = {
    {
      -- name = "Launch",
      type = "node2",
      request = "launch",
      program = "${workspaceFolder}/${file}",
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = "inspector",
      console = "integratedTerminal",
    },
  }
end

return M
