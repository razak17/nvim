local tools = {}
local conf = require('modules.tools.config')

-- tools['tpope/vim-fugitive'] = {event = 'VimEnter'}

-- tools['mbbill/undotree'] = {cmd = "UndotreeToggle"}

tools['voldikss/vim-floaterm'] = {event = "VimEnter", config = conf.floaterm}

tools['MattesGroeger/vim-bookmarks'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.bookmarks
}

tools['iamcco/markdown-preview.nvim'] = {
  ft = 'markdown',
  config = function()
    vim.g.mkdp_auto_start = 0
  end
}

tools['brooth/far.vim'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = function()
    vim.g['far#source'] = 'rg'
    vim.g['far#enable_undo'] = 1
  end
}

-- tools['kristijanhusak/vim-dadbod-ui'] = {
--   cmd = {
--     'DBUIToggle',
--     'DBUIAddConnection',
--     'DBUI',
--     'DBUIFindBuffer',
--     'DBUIRenameBuffer'
--   },
--   config = conf.vim_dadbod_ui,
--   requires = {
--     {'tpope/vim-dadbod', opt = true},
--     {'kristijanhusak/vim-dadbod-completion', opt = true}
--   }
-- }

return tools
