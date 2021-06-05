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
