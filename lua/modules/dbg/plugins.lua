local dbg = {}
local conf = require('modules.dbg.config')
local G = require 'core.global'

dbg['mfussenegger/nvim-dap'] = {config = conf.dap}

return dbg
