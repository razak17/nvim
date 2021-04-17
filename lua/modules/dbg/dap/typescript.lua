local dap = require 'dap'
local G = require 'core.global'

dap.adapters.node2 = {
  type = 'executable',
  command = 'node',
  args = {G.cache_dir .. 'dap/vscode-node-debug2/out/src/nodeDebug.js'}
}

dap.configurations.javascript = {
  {
    type = 'node2',
    request = 'launch',
    program = '${workspaceFolder}/${file}',
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = 'inspector',
    console = 'integratedTerminal'
  }
}
