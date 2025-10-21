if not ar or ar.none then return end

local bo, wo = vim.bo, vim.wo

wo.spell = false
bo.shiftwidth = 4
bo.tabstop = 4
bo.softtabstop = 4
bo.commentstring = '// %s'
vim.cmd([[setlocal path+=/usr/include/**,/usr/local/include/**]])

if not ar.plugins.enable or ar.plugins.minimal or not ar.has('nvim-dap') then
  return
end

local dap = require('dap')
local codelldb_path = ar.get_pkg_path('codelldb', 'extension/adapter/codelldb')

dap.adapters.codelldb = {
  type = 'server',
  port = '${port}',
  executable = {
    command = codelldb_path,
    args = { '--port', '${port}' },
  },
}

for _, language in ipairs({ 'c', 'cpp' }) do
  dap.configurations[language] = {
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
