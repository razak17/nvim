return function()
  local config = require('user.modules.tools.dap.config')
  require('dap').defaults.fallback.terminal_win_cmd = '50vsplit new'
  -- DON'T automatically stop at exceptions
  require('dap').defaults.fallback.exception_breakpoints = {}
  config.setup()
end
