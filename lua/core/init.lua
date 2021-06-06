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

  require('core.autocommands')
  require('keymap')
end

load_core()

r17.augroup("OnEnter", {
  {
    events = {"VimEnter", "BufReadPre"},
    targets = {"*"},
    command = function() require'internal.utils'.on_file_enter() end
  }
})
