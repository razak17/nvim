local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

ar.pack.add({
  {
    src = 'https://github.com/sammce/fleeting.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('fleeting.nvim', condition)
    end,
    lazy = false,
    init = function()
      ar.add_to_select(
        'command_palette',
        { ['Time Spent In Neovim'] = 'Fleeting' }
      )
    end,
  },
  {
    src = 'https://github.com/mrquantumcodes/configpulse',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('configpulse', condition)
    end,
    lazy = false,
    init = function()
      ar.add_to_select('command_palette', {
        ['Time Since Neovim Config'] = 'lua require"configpulse".find_time()',
      })
    end,
  },
  {
    src = 'https://github.com/blumaa/ohne-accidents',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('ohne-accidents', condition)
    end,
    cmd = { 'OhneAccidents' },
    init = function()
      ar.add_to_select('command_palette', {
        ['Days Without Configuring Neovim'] = 'OhneAccidents',
      })
    end,
    setup = function()
      require('ohne-accidents').setup({ welcomeOnStartup = false })
    end,
  },
})
