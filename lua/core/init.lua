local startup = require 'internal.startup'

local load_core = function()
  startup.disable_builtin_plugins()
  startup.disable_providers()
  startup.set_host_prog()
  startup.global_utils()
  startup.map_leader()

  local plug = require('core.plug')

  require('core.opts')
  require('core.binds')
  require('core.globals')

  plug.ensure_plugins()
  plug.load_compile()

  require('keymap')
  require('core.autocmds')
end

load_core()

-- vim.defer_fn(vim.schedule_wrap(function()
--   vim.cmd [[filetype on]]
--   vim.opt.syntax = 'on'
--   vim.defer_fn(function()
--     vim.cmd [[syntax on]]
--   end, 50)
-- end), 0)
