local conf = require('modules.aesth.conf')

local load_aesth = function()
  conf.bg()
  conf.hijackc()
  conf.bufferline()
  conf.nvim_tree()
  conf.illuminate()
  conf.colorizer()
  conf.cool()
  require('modules.aesth.statusline')
  require('modules.aesth.dashboard')
end

load_aesth()
