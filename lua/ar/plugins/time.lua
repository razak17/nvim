local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  ------------------------------------------------------------------------------
  -- Config Time
  {
    'sammce/fleeting.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('fleeting.nvim', condition)
    end,
    lazy = false,
    init = function()
      ar.add_to_select_menu(
        'command_palette',
        { ['Time Spent In Neovim'] = 'Fleeting' }
      )
    end,
  },
  {
    'mrquantumcodes/configpulse',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('configpulse', condition)
    end,
    lazy = false,
    init = function()
      ar.add_to_select_menu('command_palette', {
        ['Time Since Neovim Config'] = 'lua require"configpulse".find_time()',
      })
    end,
  },
  {
    'blumaa/ohne-accidents',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('ohne-accidents', condition)
    end,
    cmd = { 'OhneAccidents' },
    opts = { welcomeOnStartup = false },
    init = function()
      ar.add_to_select_menu('command_palette', {
        ['Days Without Configuring Neovim'] = 'OhneAccidents',
      })
    end,
    config = function(_, opts) require('ohne-accidents').setup(opts) end,
  },
}
