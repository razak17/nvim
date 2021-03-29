local tools = {}
local conf = require('modules.tools.conf')

tools['brooth/far.vim'] = {cmd = {'Far', 'Farp'}, config = conf.far}

tools['liuchengxu/vista.vim'] = {cmd = 'Vista', config = conf.vim_vista}

tools['AndrewRadev/tagalong.vim'] = {config = conf.tagalong}

tools['mbbill/undotree'] = {}

tools['tweekmonster/startuptime.vim'] = {cmd = "StartupTime"}

tools['glacambre/firenvim'] = {
  run = function()
    vim.fn['firenvim#install'](0)
  end
}

return tools
