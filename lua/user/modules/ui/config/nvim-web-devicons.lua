return function()
  local status_ok, nvim_web_devicons = rvim.safe_require('nvim-web-devicons')
  if not status_ok then
    return
  end

  local P = rvim.palette

  nvim_web_devicons.set_icon({
    sh = {
      ico = '',
      color = P.chartreuse,
      cterm_color = '59',
      name = 'Sh',
    },
    ['.gitattributes'] = {
      icon = '',
      color = P.dark_red,
      cterm_color = '59',
      name = 'GitAttributes',
    },
    ['.gitconfig'] = {
      icon = '',
      color = P.dark_red,
      cterm_color = '59',
      name = 'GitConfig',
    },
    ['.gitignore'] = {
      icon = '',
      color = P.dark_red,
      cterm_color = '59',
      name = 'GitIgnore',
    },
    ['.gitlab-ci.yml'] = {
      icon = '',
      color = P.dark_red,
      cterm_color = '166',
      name = 'GitlabCI',
    },
    ['.gitmodules'] = {
      icon = '',
      color = P.dark_red,
      cterm_color = '59',
      name = 'GitModules',
    },
    ['diff'] = {
      icon = '',
      color = P.dark_red,
      cterm_color = '59',
      name = 'Diff',
    },
  })
end
