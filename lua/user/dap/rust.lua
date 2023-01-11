local dap = require('dap')

dap.adapters.codelldb = {
  type = 'server',
  port = '${port}',
  executable = {
    command = join_paths(rvim.path.mason, 'bin', 'codelldb'),
    args = { '--port', '${port}' },
  },
}

-- Rust
dap.configurations.rust = {
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
dap.configurations.c = dap.configurations.rust
-- CPP
dap.configurations.cpp = dap.configurations.rust
