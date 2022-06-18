local dap = require("dap")
local M = {}

function M.setup()
  dap.adapters.python = {
    type = "executable",
    command = rvim.dap.python_dir,
    args = { "-m", "debugpy.adapter" },
  }

  -- Python
  dap.configurations.python = {
    {
      type = "python",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      pythonPath = function()
        local cwd = vim.fn.getcwd()
        if rvim._exists(cwd .. "/venv/bin/python") then
          return cwd .. "/venv/bin/python"
        elseif rvim._exists(cwd .. "/.venv/bin/python") then
          return cwd .. "/.venv/bin/python"
        else
          return rvim.dap.python_dir
        end
      end,
    },
  }
end

return M
