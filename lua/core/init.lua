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
  local plug = require 'core.plug'
  require 'core.opts'
  plug.ensure_plugins()
  plug.load_compile()
end

defer()
load_core()
