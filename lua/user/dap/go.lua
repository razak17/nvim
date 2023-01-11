local dap = require('dap')

dap.adapters.go = {
  type = 'server',
  port = '${port}',
  executable = {
    command = join_paths(rvim.path.mason, 'bin', 'dlv'),
    args = { 'dap', '-l', '127.0.0.1:${port}' },
  },
}

dap.configurations.go = {
  {
    type = 'go', -- Which adapter to use
    name = 'Debug', -- Human readable name
    request = 'launch', -- Whether to "launch" or "attach" to program
    program = '${file}', -- The buffer you are focused on when running nvim-dap
  },
  {
    type = 'go',
    name = 'Debug test (go.mod)',
    request = 'launch',
    mode = 'test',
    program = './${relativeFileDirname}',
  },
  {
    type = 'go',
    name = 'Attach (Pick Process)',
    mode = 'local',
    request = 'attach',
    processId = require('dap.utils').pick_process,
  },
  {
    type = 'go',
    name = 'Attach (127.0.0.1:9080)',
    mode = 'remote',
    request = 'attach',
    port = '9080',
  },
}
