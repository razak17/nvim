local G = require 'core.globals'
local dap = require 'dap'

dap.adapters.python = {
  type = 'executable',
  command = G.dap .. 'bin/python',
  args = {'-m', 'debugpy.adapter'}
}

dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = "Launch file",
    program = "${file}",
    pythonPath = function()
      local cwd = vim.fn.getcwd()
      if G.exists(cwd .. '/venv/bin/python') then
        return cwd .. '/venv/bin/python'
      elseif G.exists(cwd .. '/.venv/bin/python') then
        return cwd .. '/.venv/bin/python'
      else
        return G.dap .. 'bin/python'
      end
    end
  }
}
