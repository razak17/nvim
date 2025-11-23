local minimal = ar.plugins.minimal

return {
  {
    'nvzone/timerly',
    cond = function() return ar.get_plugin_cond('timerly', not minimal) end,
    cmd = 'TimerlyToggle',
    init = function()
      ar.add_to_select_menu('command_palette', {
        ['Toggle Timer'] = 'TimerlyToggle',
      })
    end,
    dependencies = { 'nvzone/volt' },
  },
  {
    'nvzone/showkeys',
    cond = function() return ar.get_plugin_cond('showkeys', not minimal) end,
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
    dependencies = { 'nvzone/volt' },
  },
  {
    'nvzone/minty',
    cond = function() return ar.get_plugin_cond('minty', not minimal) end,
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
    dependencies = { 'nvzone/volt' },
  },
}
