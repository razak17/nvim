local minimal = ar.plugins.minimal
return {
  --------------------------------------------------------------------------------
  -- Share Code
  {
    'TobinPalmer/rayso.nvim',
    cmd = { 'Rayso' },
    cond = function() return ar.get_plugin_cond('rayso.nvim', not minimal) end,
    opts = {},
  },
  {
    'ellisonleao/carbon-now.nvim',
    cmd = 'CarbonNow',
    cond = function() return ar.get_plugin_cond('carbon-now.nvim', not minimal) end,
    opts = {},
  },
  {
    'Sanix-Darker/snips.nvim',
    cmd = { 'SnipsCreate' },
    cond = function() return ar.get_plugin_cond('snips.nvim', not minimal) end,
    opts = {},
  },
  {
    'ethanholz/freeze.nvim',
    cmd = 'Freeze',
    cond = function() return ar.get_plugin_cond('freeze.nvim', not minimal) end,
    opts = {},
  },
  {
    'LionyxML/nvim-0x0',
    cond = function() return ar.get_plugin_cond('nvim-0x0', not minimal) end,
    init = function()
      ar.add_to_select_menu('command_palette', {
        ['Upload Current File To 0x0.st'] = function()
          require('nvim-0x0').upload_current_file()
        end,
        ['Upload Selection To 0x0.st'] = function()
          require('nvim-0x0').upload_selection()
        end,
        ['Upload Yank To 0x0.st'] = function()
          require('nvim-0x0').upload_yank()
        end,
      })
    end,
    opts = { use_default_keymaps = false },
  },
}
