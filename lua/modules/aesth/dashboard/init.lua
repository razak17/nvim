local G = require 'core.global'
local g = vim.g

vim.cmd [[
  let g:dashboard_custom_header =<< trim END
    =================     ===============     ===============   ========  ========
    \\ . . . . . . .\\   //. . . . . . .\\   //. . . . . . .\\  \\. . .\\// . . //
    ||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\/ . . .||
    || . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . ||
    ||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . .||
    || . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\ . . . . ||
    ||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\_ . .|. .||
    || . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\ `-_/| . ||
    ||_-' ||  .|/    || ||    \|.  || `-_|| ||_-' ||  .|/    || ||   | \  / |-_.||
    ||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \  / |  `||
    ||    `'         || ||         `'    || ||    `'         || ||   | \  / |   ||
    ||            .===' `===.         .==='.`===.         .===' /==. |  \/  |   ||
    ||         .=='   \_|-_ `===. .==='   _|_   `===. .===' _-|/   `==  \/  |   ||
    ||      .=='    _-'    `-_  `='    _-'   `-_    `='  _-'   `-_  /|  \/  |   ||
    ||   .=='    _-'          '-__\._-'         '-_./__-'         `' |. /|  |   ||
    ||.=='    _-'                                                     `' |  /==.||
    =='    _-'                        N E O V I M                         \/   `==
    \   _-'                                                                `-_   /
    `''                                                                      ``'
  END
]]

g.dashboard_footer_icon = '🍔 '
g.dashboard_preview_pipeline = 'lolcat -F 0.3'
-- g.dashboard_preview_command = 'cat'
-- g.dashboard_preview_file = G.home .. '.config/nvim/static/neovim.cat'
g.dashboard_preview_file_height = 12
g.dashboard_preview_file_width = 70
g.dashboard_default_executive = 'telescope'
g.dashboard_custom_section = {
  last_session = {
    description = {'  Load last session                 SPC s l'},
    command = 'SessionLoad'
  },
  find_history = {
    description = {'  Recent files                      SPC f h'},
    command = 'DashboardFindHistory'
  },
  find_file = {
    description = {'  Find  File                        SPC f f'},
    command = 'Telescope find_files find_command=rg,--hidden,--files'
  },
  file_browser = {
    description = {'  File Browser                      SPC f b'},
    command = 'Telescope file_browser'
  },
  find_word = {
    description = {'  Find  word                        SPC f w'},
    command = 'DashboardFindWord'
  },
  find_dotfiles = {
    description = {'  Open Personal dotfiles            SPC f d'},
    command = 'Telescope dotfiles path=' .. G.home .. 'env/nvim'
  }
}

