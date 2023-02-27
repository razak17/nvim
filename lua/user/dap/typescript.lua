local dap = require('dap')

dap.configurations.javascript = {
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Launch Current File (pwa-node)',
    cwd = vim.fn.getcwd(),
    args = { '${file}' },
    sourceMaps = true,
    protocol = 'inspector',
  },
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Launch Current File (pwa-node with ts-node)',
    cwd = vim.fn.getcwd(),
    runtimeArgs = { '--loader', 'ts-node/esm' },
    runtimeExecutable = 'node',
    args = { '${file}' },
    sourceMaps = true,
    protocol = 'inspector',
    skipFiles = { '<node_internals>/**', 'node_modules/**' },
    resolveSourceMapLocations = {
      '${workspaceFolder}/**',
      '!**/node_modules/**',
    },
  },
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Launch Current File (pwa-node with deno)',
    cwd = vim.fn.getcwd(),
    runtimeArgs = { 'run', '--inspect-brk', '--allow-all', '${file}' },
    runtimeExecutable = 'deno',
    attachSimplePort = 9229,
  },
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Launch Test Current File (pwa-node with jest)',
    cwd = vim.fn.getcwd(),
    runtimeArgs = { '${workspaceFolder}/node_modules/.bin/jest' },
    runtimeExecutable = 'node',
    args = { '${file}', '--coverage', 'false' },
    rootPath = '${workspaceFolder}',
    sourceMaps = true,
    console = 'integratedTerminal',
    internalConsoleOptions = 'neverOpen',
    skipFiles = { '<node_internals>/**', 'node_modules/**' },
  },
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Launch Test Current File (pwa-node with vitest)',
    cwd = vim.fn.getcwd(),
    program = '${workspaceFolder}/node_modules/vitest/vitest.mjs',
    args = { '--inspect-brk', '--threads', 'false', 'run', '${file}' },
    autoAttachChildProcesses = true,
    smartStep = true,
    console = 'integratedTerminal',
    skipFiles = { '<node_internals>/**', 'node_modules/**' },
  },
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Launch Test Current File (pwa-node with deno)',
    cwd = vim.fn.getcwd(),
    runtimeArgs = { 'test', '--inspect-brk', '--allow-all', '${file}' },
    runtimeExecutable = 'deno',
    attachSimplePort = 9229,
  },
  {
    type = 'pwa-chrome',
    request = 'attach',
    name = 'Attach Program (pwa-chrome = { port: 9222 })',
    program = '${file}',
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    port = 9222,
    webRoot = '${workspaceFolder}',
  },
  -- {
  --   type = 'node2',
  --   request = 'attach',
  --   name = 'Attach Program (Node2)',
  --   processId = require('dap.utils').pick_process,
  -- },
  -- {
  --   type = 'node2',
  --   request = 'attach',
  --   name = 'Attach Program (Node2 with ts-node)',
  --   cwd = vim.fn.getcwd(),
  --   sourceMaps = true,
  --   skipFiles = { '<node_internals>/**' },
  --   port = 9229,
  -- },
  {
    type = 'pwa-node',
    request = 'attach',
    name = 'Attach Program (pwa-node, select pid)',
    cwd = vim.fn.getcwd(),
    processId = require('dap.utils').pick_process,
    skipFiles = { '<node_internals>/**' },
  },
}
dap.configurations.typescript = dap.configurations.javascript
dap.configurations.javascriptreact = dap.configurations.javascript
dap.configurations.typescriptreact = dap.configurations.javascript

-- using pwa-chrome
dap.configurations.vue = dap.configurations.javascript
dap.configurations.svelte = dap.configurations.javascript
