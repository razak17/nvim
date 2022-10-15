local M = {}

function M.attach()
  print('attaching')
  require('dap').run({
    type = 'node2',
    request = 'attach',
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = 'inspector',
    skipFiles = { '<node_internals>/**/*.js' },
  })
end

function M.attach_to_remote()
  print('attaching')
  require('dap').run({
    type = 'node2',
    request = 'attach',
    address = '127.0.0.1',
    port = 9229,
    localRoot = vim.fn.getcwd(),
    remoteRoot = '/home/vcap/app',
    sourceMaps = true,
    protocol = 'inspector',
    skipFiles = { '<node_internals>/**/*.js' },
  })
end

return M
