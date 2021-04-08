local home = os.getenv('HOME')
local g = vim.g

g.dashboard_footer_icon = '🐬 '
g.dashboard_preview_command = 'cat'
g.dashboard_preview_pipeline = 'lolcat'
g.dashboard_preview_file = home .. '/.config/nvim/static/pokemon.txt'
g.dashboard_preview_file_height = 12
g.dashboard_preview_file_width = 80
g.dashboard_default_executive = 'telescope'
g.dashboard_custom_section = {
  last_session = {
    description = {'  Recently laset session                  SPC s l'},
    command = 'SessionLoad'
  },
  find_history = {
    description = {'  Recently opened files                   SPC f h'},
    command = 'DashboardFindHistory'
  },
  find_file = {
    description = {'  Find  File                              SPC f f'},
    command = 'DashboardFindFile'
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

