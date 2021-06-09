local load_niceties = function()
  vim.defer_fn(vim.schedule_wrap(function()
    require('keymap')
    require('core.binds')
    require('core.autocommands')
    vim.defer_fn(function()
      vim.cmd [[syntax on]]
      vim.cmd [[filetype plugin indent  on]]
      vim.cmd [[verbose set formatoptions-=cro]]
    end, 250)
  end), 0)
end

local load_core = function()
  local plug = require('core.plug')
  require'internal.startup'.init()
  require('core.opts')
  require('core.globals')
  load_niceties()
  plug.ensure_plugins()
  plug.load_compile()
end

load_core()
