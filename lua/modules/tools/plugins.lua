local tools = {}
local conf = require('modules.tools.config')

tools['mbbill/undotree'] = {cmd = "UndotreeToggle"}

tools['kevinhwang91/rnvimr'] = {config = conf.rnvimr}

tools['voldikss/vim-floaterm'] = {config = conf.floaterm}

tools['tweekmonster/startuptime.vim'] = {cmd = "StartupTime"}

tools['liuchengxu/vista.vim'] = {cmd = 'Vista', config = conf.vim_vista}

tools['MattesGroeger/vim-bookmarks'] = {config = conf.bookmarks}

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

tools['kevinhwang91/nvim-bqf'] = {
  config = function()
    require('bqf').setup({
      auto_enable = true,
      preview = {win_height = 12, win_vheight = 12, delay_syntax = 80},
      func_map = {vsplit = '<C-v>', ptogglemode = 'z,', stoggleup = 'z<Tab>'},
      filter = {
        fzf = {
          action_for = {['ctrl-s'] = 'split'},
          extra_opts = {'--bind', 'ctrl-o:toggle-all', '--prompt', '> '}
        }
      }
    })
  end
}

return tools
