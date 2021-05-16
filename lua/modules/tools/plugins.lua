local tools = {}
local conf = require('modules.tools.config')

tools['mbbill/undotree'] = {cmd = "UndotreeToggle"}

tools['voldikss/vim-floaterm'] = {config = conf.floaterm}

tools['tweekmonster/startuptime.vim'] = {cmd = "StartupTime"}

tools['MattesGroeger/vim-bookmarks'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.bookmarks
}

tools['glacambre/firenvim'] = {
  run = function()
    vim.fn['firenvim#install'](0)
  end
}

tools['iamcco/markdown-preview.nvim'] = {
  ft = 'markdown',
  config = function()
    vim.g.mkdp_auto_start = 0
  end
}

tools['brooth/far.vim'] = {
  event = {'BufReadPre', 'BufNewFile'},
  cmd = {'Far', 'Farr', 'Farp', 'Farf'},
  config = function()
    vim.g['far#source'] = 'rg'
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

return tools
