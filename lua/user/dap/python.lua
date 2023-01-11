local dap = require('dap')
local python_dir = join_paths(rvim.path.mason, 'packages', 'debugpy', 'venv', 'bin', 'python')

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
      local cwd = vim.fn.getcwd()
      if rvim.executable(join_paths(cwd, 'venv', 'bin', 'python')) then
        return join_paths(cwd .. 'venv', 'bin', 'python')
      end
      if rvim.executable(join_paths(cwd, '.venv', 'bin', 'python')) then
        return join_paths(cwd, '.venv', 'biv', 'python')
      end
      return python_dir
    end,
  },
}
