local tools = {}
local conf = require('modules.tools.config')

tools['tpope/vim-fugitive'] = {}

tools['mbbill/undotree'] = {cmd = "UndotreeToggle"}

tools['kevinhwang91/rnvimr'] = {config = conf.rnvimr}

tools['glepnir/prodoc.nvim'] = {event = 'BufReadPre'}

tools['voldikss/vim-floaterm'] = {config = conf.floaterm}

tools['tweekmonster/startuptime.vim'] = {cmd = "StartupTime"}

tools['liuchengxu/vista.vim'] = {cmd = 'Vista', config = conf.vim_vista}

tools['brooth/far.vim'] = {
  cmd = {'Far', 'Farr', 'Farp', 'Farf'},
  config = function()
    vim.g['far#source'] = 'rg'
  end
}

tools['iamcco/markdown-preview.nvim'] = {
  ft = 'markdown',
  config = function()
    vim.g.mkdp_auto_start = 0
  end
}

tools['kristijanhusak/vim-dadbod-ui'] = {
  cmd = {
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUI',
    'DBUIFindBuffer',
    'DBUIRenameBuffer'
  },
  config = conf.vim_dadbod_ui,
  requires = {{'tpope/vim-dadbod', opt = true}}
}

tools['glacambre/firenvim'] = {
  run = function()
    vim.fn['firenvim#install'](0)
  end
}

return tools
