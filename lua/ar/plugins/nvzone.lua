local minimal = ar.plugins.minimal

return {
  'nvzone/volt',
  {
    'nvzone/timerly',
    cond = not minimal,
    cmd = 'TimerlyToggle',
    init = function()
      ar.add_to_select_menu('command_palette', {
        ['Toggle Timer'] = 'TimerlyToggle',
      })
    end,
  },
  {
    'nvzone/showkeys',
    cond = not minimal,
    init = function()
      ar.add_to_select_menu(
        'command_palette',
        { ['Toggle Screencaster'] = 'ShowkeysToggle' }
      )
    end,
    cmd = 'ShowkeysToggle',
    opts = {
      position = 'top-right',
      timeout = 1,
      maxkeys = 17,
    },
  },
  {
    'nvzone/minty',
    cond = not minimal,
    cmd = { 'Shades', 'Huefy' },
    init = function()
      ar.add_to_select_menu('toggle', {
        ['Toggle Color Picker'] = 'Huefy',
      })
    end,
    keys = {
      {
        '<leader>oP',
        '<Cmd>lua require("minty.huefy").open( { border = true } )<CR>',
        desc = 'toggle minty',
      },
    },
    config = function()
      require('minty.huefy').open()
      require('minty.shades').open()
    end,
  },
}
