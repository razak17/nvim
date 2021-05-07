local tools = {}
local conf = require('modules.tools.config')

tools['mbbill/undotree'] = {cmd = "UndotreeToggle"}

tools['kevinhwang91/nvim-bqf'] = {config = conf.bqf}

tools['tweekmonster/startuptime.vim'] = {cmd = "StartupTime"}

tools['liuchengxu/vista.vim'] = {cmd = 'Vista', config = conf.vim_vista}

tools['MattesGroeger/vim-bookmarks'] = {
  config = conf.bookmarks
}

tools['voldikss/vim-floaterm'] = {config = conf.floaterm}

tools['brooth/far.vim'] = {
  event = {'BufReadPre', 'BufNewFile'},
  cmd = {'Far', 'Farr', 'Farp', 'Farf'},
  config = function()
    vim.g['far#source'] = 'rg'
  end
}

tools['iamcco/markdown-preview.nvim'] = {
  event = {'BufReadPre', 'BufNewFile'},
  ft = 'markdown',
  config = function()
    vim.g.mkdp_auto_start = 0
  end
}

tools['glacambre/firenvim'] = {
  run = function()
    vim.fn['firenvim#install'](0)
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
