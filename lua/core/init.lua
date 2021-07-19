local function load_core()
  require 'core.opts'
  local plug = require 'core.plug'
  plug.ensure_plugins()
  plug.load_compile()
end

local defer = function()
  vim.defer_fn(vim.schedule_wrap(function()
    require 'keymap'
    require 'core.binds'
    vim.defer_fn(function()
      vim.cmd [[colo zephyr]]
      vim.cmd [[syntax on]]
      vim.cmd [[filetype plugin indent on]]
    end, 0)
  end), 0)
end

defer()
load_core()
