local plug = require('core.plug')

local load_niceties = function()
  vim.defer_fn(vim.schedule_wrap(function()
    require('keymap')
    require('core.binds')
    require('core.autocommands')
    plug.ensure_plugins()
    vim.defer_fn(function()
      vim.cmd [[syntax on]]
      vim.cmd [[filetype plugin indent  on]]
      vim.cmd [[verbose set formatoptions-=cro]]
    end, 250)
  end), 0)
end

local load_core = function()
  require'internal.startup'.init()

  require('core.opts')
  require('core.globals')

  plug.load_compile()
  load_niceties()
end

load_core()
