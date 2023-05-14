if not rvim then return end

local opt = vim.opt_local

opt.textwidth = 120
opt.spell = true
opt.spelllang = { 'en_gb', 'programming' }
opt.spellfile:prepend(join_paths(vim.fn.stdpath('config'), 'spell', 'lua.utf-8.add'))
opt.iskeyword:append('-')

if vim.env.RVIM_LSP_ENABLED == '0' or vim.env.RVIM_PLUGINS_ENABLED == '0' then return end

local dap = require('dap')

dap.adapters.nlua = function(callback, config)
  callback({ type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 })
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
