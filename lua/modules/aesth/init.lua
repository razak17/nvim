local load_config = require 'utils.funcs'.load_config
local conf = require('modules.aesth.config')

local load_aesth = function()
  conf.bg()
  conf.hijackc()
  conf.bufferline()
  load_config('modules.aesth.statusline')
  load_config('modules.aesth.dashboard')
end

load_aesth()
