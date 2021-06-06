local g = vim.g
local G = require 'core.globals'

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

g.dashboard_footer_icon = ''
g.dashboard_preview_pipeline = 'lolcat -F 0.3'
g.dashboard_preview_file_height = 12
g.dashboard_preview_file_width = 70
g.dashboard_default_executive = 'telescope'
g.dashboard_session_directory = G.cache_dir .. 'sessions'
g.dashboard_custom_section = {
  find_history = {
    description = {'  Recent files                      SPC f r r'},
    command = 'Telescope oldfiles'
  },
  find_file = {
    description = {'  Find File                         SPC f f  '},
    command = 'Telescope find_files find_command=rg,--hidden,--files'
  },
  file_browser = {
    description = {'  File Browser                      SPC f b  '},
    command = 'Telescope file_browser'
  },
  find_word = {
    description = {'  Find word                         SPC f l g'},
    command = 'Telescope live_grep'
  },
  last_session = {
    description = {'  Load last session                 SPC S l  '},
    command = 'SessionLoad'
  },
  find_dotfiles = {
    description = {'  Nvim config files                 SPC f r c'},
    command = 'Telescope nvim_files files'
  }
}

r17.augroup("DashBoardMode", {
  {
    events = {"FocusGained", "WinEnter"},
    targets = {"dashboard"},
    command = "setlocal nocursorline showtabline=0"
  }, {
    events = {"FocusLost", "WinLeave"},
    targets = {"dashboard"},
    command = "set colorcolumn=+1 showtabline=2"
  }
})
