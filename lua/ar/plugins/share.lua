local minimal = ar.plugins.minimal
return {
  --------------------------------------------------------------------------------
  -- Share Code
  {
    'TobinPalmer/rayso.nvim',
    cmd = { 'Rayso' },
    cond = not minimal,
    opts = {},
  },
  {
    'ellisonleao/carbon-now.nvim',
    cmd = 'CarbonNow',
    cond = not minimal,
    opts = {},
  },
  {
    'Sanix-Darker/snips.nvim',
    cmd = { 'SnipsCreate' },
    cond = not minimal,
    opts = {},
  },
  {
    'ethanholz/freeze.nvim',
    cmd = 'Freeze',
    cond = not minimal,
    opts = {},
  },
  {
    'LionyxML/nvim-0x0',
    cond = not minimal,
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
