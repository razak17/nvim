local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  ------------------------------------------------------------------------------
  -- Config Time
  {
    'sammce/fleeting.nvim',
    cond = not minimal and niceties,
    lazy = false,
    init = function()
      ar.add_to_menu(
        'command_palette',
        { ['Time Spent In Neovim'] = 'Fleeting' }
      )
    end,
  },
  {
    'mrquantumcodes/configpulse',
    cond = not minimal and niceties,
    lazy = false,
    init = function()
      ar.add_to_menu('command_palette', {
        ['Time Since Neovim Config'] = 'lua require"configpulse".find_time()',
      })
    end,
  },
  {
    'blumaa/ohne-accidents',
    cond = not minimal and niceties,
    cmd = { 'OhneAccidents' },
    opts = { welcomeOnStartup = false },
    init = function()
      ar.add_to_menu('command_palette', {
        ['Days Without Configuring Neovim'] = 'OhneAccidents',
      })
    end,
    config = function(_, opts) require('ohne-accidents').setup(opts) end,
  },
}
