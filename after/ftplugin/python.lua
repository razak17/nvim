if rvim and rvim.none then return end

local bo, opt = vim.bo, vim.opt_local

bo.tabstop = 4
bo.softtabstop = 4
bo.shiftwidth = 4
opt.spell = true

if
  not rvim
  or not rvim.lsp.enable
  or not rvim.plugins.enable
  or rvim.plugins.minimal
then
  return
end

local dap = require('dap')
local mason_registry = require('mason-registry')
local debugpy_path = mason_registry.get_package('debugpy'):get_install_path()
  .. '/venv/bin/python'

dap.adapters.python = function(cb, config)
  if config.request == 'attach' then
    local port = (config.connect or config).port
    local host = (config.connect or config).host or '127.0.0.1'
    cb({
      type = 'server',
      port = assert(
        port,
        '`connect.port` is required for a python `attach` configuration'
      ),
      host = host,
      options = { source_filetype = 'python' },
    })
  else
    cb({
      type = 'executable',
      command = debugpy_path,
      args = { '-m', 'debugpy.adapter' },
      options = { source_filetype = 'python' },
    })
  end
end
dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    program = '${file}',
    pythonPath = function()
      local fn = vim.fn
      local cwd = fn.getcwd()
      if fn.executable(join_paths(cwd, 'venv', 'bin', 'python')) == 1 then
        return join_paths(cwd, '/venv', 'bin', 'python')
      end
      if fn.executable(join_paths(cwd, '.venv', 'bin', 'python')) == 1 then
        return join_paths(cwd, '.venv', 'bin', 'python')
      end
      return debugpy_path
    end,
  },
}
