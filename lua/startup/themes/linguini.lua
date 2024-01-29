local settings = {
  header = {
    type = 'text',
    align = 'center',
    fold_section = false,
    title = 'Header',
    margin = 3,
    content = require('startup.custom_headers').conway,
    highlight = '@variable',
    oldfiles_amount = 0,
  },
  clock = {
    type = 'text',
    content = function()
      local time = '' .. os.date('%H:%M')
      local date = '' .. os.date('%Y-%m-%d')
      return { date, time }
    end,
    oldfiles_directory = false,
    align = 'center',
    fold_section = false,
    title = '',
    margin = 3,
    highlight = '@variable',
  },
  statistics = {
    type = 'text',
    content = function()
      local fmt = string.format
      local v = vim.version()
      local version = fmt(
        'Neovim v%d.%d.%d %s',
        v.major,
        v.minor,
        v.patch,
        v.prerelease and '(nightly)' or ''
      )
      return { version }
    end,
    oldfiles_directory = false,
    align = 'center',
    fold_section = false,
    title = '',
    margin = 3,
    highlight = '@comment',
  },
  parts = { 'header', 'clock', 'statistics' },
}
return settings
