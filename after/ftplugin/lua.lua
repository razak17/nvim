if rvim and rvim.none then return end

local opt = vim.opt_local

opt.textwidth = 80
opt.spell = true
opt.iskeyword:append('-')

if not rvim or not rvim.lsp.enable or not rvim.plugins.enable then return end

opt.spellfile:prepend(
  join_paths(vim.fn.stdpath('config'), 'spell', 'lua.utf-8.add')
)
opt.spelllang = { 'en_gb', 'programming' }

if rvim.plugins.minimal then return end

local dap = require('dap')

dap.adapters.nlua = function(callback, config)
  callback({
    type = 'server',
    host = config.host or '127.0.0.1',
    port = config.port or 8086,
  })
end
dap.configurations.lua = {
  {
    type = 'nlua',
    request = 'attach',
    name = 'Attach to running Neovim instance',
    host = function()
      local value = vim.fn.input('Host [127.0.0.1]: ')
      return value ~= '' and value or '127.0.0.1'
    end,
    port = function()
      local val = tonumber(vim.fn.input('Port: '))
      assert(val, 'Please provide a port number')
      return val
    end,
  },
}
