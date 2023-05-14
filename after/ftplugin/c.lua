local mason_registry = require('mason-registry')
local codelldb_path = mason_registry.get_package('codelldb'):get_install_path() .. '/extension/adapter/codelldb'
local dap = require('dap')

dap.adapters.codelldb = {
  type = 'server',
  port = '${port}',
  executable = {
    command = codelldb_path,
    args = { '--port', '${port}' },
  },
}
for _, language in ipairs({ 'c', 'cpp' }) do
  require('dap').configurations[language] = {
    {
      name = 'Launch file',
      type = 'codelldb',
      request = 'launch',
      program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
    },
  }
end
