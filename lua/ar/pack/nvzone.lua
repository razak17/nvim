local minimal = ar.plugins.minimal

ar.pack.add({
  {
    src = 'https://github.com/nvzone/timerly',
    cond = function() return ar.get_plugin_cond('timerly', not minimal) end,
    cmd = 'TimerlyToggle',
    init = function()
      ar.add_to_select('command_palette', {
        ['Toggle Timer'] = 'TimerlyToggle',
      })
    end,
    dependencies = {
      { src = 'https://github.com/nvzone/volt' },
    },
  },
  {
    src = 'https://github.com/nvzone/showkeys',
    cond = function() return ar.get_plugin_cond('showkeys', not minimal) end,
    init = function()
      ar.add_to_select(
        'command_palette',
        { ['Toggle Screencaster'] = 'ShowkeysToggle' }
      )
    end,
    cmd = 'ShowkeysToggle',
    dependencies = {
      { src = 'https://github.com/nvzone/volt' },
    },
    setup = function()
      require('showkeys').setup({
        position = 'top-right',
        timeout = 1,
        maxkeys = 17,
      })
    end,
  },
  {
    src = 'https://github.com/nvzone/minty',
    cond = function() return ar.get_plugin_cond('minty', not minimal) end,
    cmd = { 'Shades', 'Huefy' },
    init = function()
      ar.add_to_select('toggle', {
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
    dependencies = {
      { src = 'https://github.com/nvzone/volt' },
    },
    setup = function()
      require('minty.huefy').open()
      require('minty.shades').open()
    end,
  },
  {
    src = 'https://github.com/aikhe/wrapped.nvim',
    cond = function() return ar.get_plugin_cond('wrapped.nvim', not minimal) end,
    cmd = { 'NvimWrapped' },
    dependencies = {
      { src = 'https://github.com/nvzone/volt' },
    },
    setup = function() require('wrapped').setup() end,
  },
})
