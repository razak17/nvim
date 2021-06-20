local dap = require 'dap'

dap.adapters.python = {
  type = 'executable',
  command = r17._dap .. 'bin/python',
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
      if r17._exists(cwd .. '/venv/bin/python') then
        return cwd .. '/venv/bin/python'
      elseif r17._exists(cwd .. '/.venv/bin/python') then
        return cwd .. '/.venv/bin/python'
      else
        return r17._dap .. 'bin/python'
      end
    end
  }
}
