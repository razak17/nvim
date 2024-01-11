if not rvim or rvim.none then return end

local bo, wo = vim.bo, vim.wo

wo.spell = false
bo.shiftwidth = 4
bo.tabstop = 4
bo.softtabstop = 4
bo.commentstring = '// %s'
vim.cmd([[setlocal path+=/usr/include/**,/usr/local/include/**]])

if not rvim.plugins.enable or rvim.plugins.minimal then return end

local mason_registry = require('mason-registry')
local codelldb_path = mason_registry.get_package('codelldb'):get_install_path()
  .. '/extension/adapter/codelldb'

require('dap').adapters.codelldb = {
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
      program = function()
        return vim.fn.input(
          'Path to executable: ',
          vim.fn.getcwd() .. '/',
          'file'
        )
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
    },
  }
end
