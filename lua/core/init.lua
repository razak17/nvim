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
  -- TODO
  require('internal.folds')

  plug.ensure_plugins()
  plug.load_compile()

  require('keymap')
  require('core.autocmd')
  require('modules.lang.ts')
end

load_core()
