if !exists('g:vscode')
  hi link DashboardHeader String
  hi link DashboardCenter Macro
  hi link DashboardShortcut PreProc
  hi link DashboardFooter Type

  let g:dashboard_default_executive ='telescope'

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
   `''
  END

  " let g:dashboard_custom_header = [
  " \ ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
  " \ ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
  " \ ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
  " \ ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
  " \ ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
  " \ ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
  " \]

  let g:dashboard_custom_section={
      \ 'last_session' :{
          \ 'description': ['    Open last session                       SPC sl   '],
          \ 'command':function('dashboard#handler#last_session')},
      \ 'find_history' :{
          \ 'description': ['   ﭯ Recently opened files                   SPC fh   '],
          \ 'command':function('dashboard#handler#find_history')},
      \ 'find_file'    :{
          \ 'description': ['    Find File                               SPC ff   '],
          \ 'command':function('dashboard#handler#find_file')},
      \ 'find_word'    :{
          \ 'description': ['    Find word                               SPC fa   '],
          \ 'command': function('dashboard#handler#find_word')},
      \ 'book_marks'   :{
          \ 'description': ['    Jump to book marks                      SPC fb   '],
          \ 'command':function('dashboard#handler#book_marks')},
      \ 'new_file'   :{
          \ 'description': ['    Create new file                         SPC cn   '],
          \ 'command':function('dashboard#handler#new_file')},
      \ 'change_colorscheme'   :{
          \ 'description': ['    Change color scheme                     SPC tc   '],
          \ 'command':function('dashboard#handler#new_file')},
      \ }

  " let s:dashboard_shortcut_icon['find_history'] = ' '
  " let g:dashboard_custom_footer = "yo"

  " autocmd FileType dashboard set showtabline=0 | autocmd WinLeave <buffer> set showtabline=2
end
