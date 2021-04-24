local home = os.getenv('HOME')
local g = vim.g

g.dashboard_footer_icon = '🐬 '
g.dashboard_preview_command = 'cat'
g.dashboard_preview_pipeline = 'lolcat -F 0.3'
g.dashboard_preview_file = home .. '/.config/nvim/static/pokemon.txt'
g.dashboard_preview_file_height = 12
g.dashboard_preview_file_width = 70
g.dashboard_default_executive = 'telescope'
g.dashboard_custom_section = {
  last_session = {
    description = {'  Recently saved session                  SPC s l'},
    command = 'SessionLoad'
  },
  find_history = {
    description = {'  Recently opened files                   SPC f h'},
    command = 'DashboardFindHistory'
  },
  find_file = {
    description = {'  Find  File                              SPC f f'},
    command = 'Telescope find_files find_command=rg,--hidden,--files'
  },
  file_browser = {
    description = {'  File Browser                            SPC f b'},
    command = 'Telescope file_browser'
  },
  new_file = {
    description = {'  New   File                              SPC t f'},
    command = 'DashboardNewFile'
  },
  find_word = {
    description = {'  Find  word                              SPC f w'},
    command = 'DashboardFindWord'
  },
  find_dotfiles = {
    description = {'  Open Personal dotfiles                  SPC f d'},
    command = 'Telescope dotfiles path=' .. home .. '/env/nvim'
  }
}

