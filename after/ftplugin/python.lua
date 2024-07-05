if not ar or ar.none then return end

local bo, opt, fn = vim.bo, vim.opt_local, vim.fn

bo.tabstop = 4
bo.softtabstop = 4
bo.shiftwidth = 4
opt.spell = true

if not ar.plugins.enable or ar.plugins.minimal then return end

local dap = require('dap')
local mason_registry = require('mason-registry')
local debugpy_path = mason_registry.get_package('debugpy'):get_install_path()
  .. '/venv/bin/python'

local pythonPath = function()
  local cwd = fn.getcwd()
  local dirs = { 'venv', '.venv', 'env', '.env' }
  for _, dir in ipairs(dirs) do
    if fn.executable(join_paths(cwd, dir, 'bin', 'python')) == 1 then
      return join_paths(cwd, dir, 'bin', 'python')
    end
  end
  return debugpy_path
end

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
      command = pythonPath(),
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
    pythonPath = pythonPath(),
  },
  {
    type = 'python',
    request = 'launch',
    name = 'DAP Django',
    program = vim.uv.cwd() .. '/manage.py',
    args = { 'runserver', '--noreload' },
    justMyCode = true,
    django = true,
    console = 'integratedTerminal',
  },
  {
    type = 'python',
    request = 'attach',
    name = 'Attach remote',
    connect = function()
      return {
        host = '127.0.0.1',
        port = 5678,
      }
    end,
  },
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file with arguments',
    program = '${file}',
    args = function()
      local args_string = vim.fn.input('Arguments: ')
      return vim.split(args_string, ' +')
    end,
    console = 'integratedTerminal',
    pythonPath = pythonPath(),
  },
}
