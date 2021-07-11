local defer = function()
  vim.defer_fn(vim.schedule_wrap(function()
    require 'keymap'
    require 'core.binds'
    vim.defer_fn(function()
      vim.cmd [[syntax on]]
      vim.cmd [[filetype plugin indent on]]
    end, 250)
  end), 0)
end

local load_core = function()
  require 'core.globals'
  require 'core.opts'
  local plug = require 'core.plug'
  plug.ensure_plugins()
  plug.load_compile()
end

load_core()
defer()
