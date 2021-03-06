local load_config = require 'utils.funcs'.load_config
local conf = require('modules.aesth.config')

local load_aesth = function()
  conf.bg()
  conf.hijackc()
  conf.bufferline()
  conf.nvim_tree()
  conf.illuminate()
  conf.colorizer()
  load_config('modules.aesth.statusline')
  load_config('modules.aesth.dashboard')
end

load_aesth()
