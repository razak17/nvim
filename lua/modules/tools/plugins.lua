local tools = {}
local conf = require('modules.tools.config')

tools['tweekmonster/startuptime.vim'] = {cmd = "StartupTime"}

tools['tpope/vim-fugitive'] = {event = {'VimEnter'}}

tools['MattesGroeger/vim-bookmarks'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.bookmarks
}

return tools
