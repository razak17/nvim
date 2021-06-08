local load_niceties = function()
  vim.defer_fn(vim.schedule_wrap(function()
    require('keymap')
    require('core.autocommands')
    vim.defer_fn(function()
      vim.cmd [[syntax on]]
      vim.cmd [[filetype plugin indent  on]]
      vim.cmd [[verbose set formatoptions-=cro]]
    end, 250)
  end), 0)
end

local load_core = function()
  require'internal.startup'.init()

  local plug = require('core.plug')

  require('core.opts')
  require('core.binds')
  require('core.globals')

  plug.ensure_plugins()
  plug.load_compile()
  load_niceties()
end

load_core()
