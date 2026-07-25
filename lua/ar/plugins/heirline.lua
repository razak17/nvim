local statusline = ar.config.ui.statusline
local statuscolumn = ar.config.ui.statuscolumn

return {
  {
    'rebelot/heirline.nvim',
    event = 'BufWinEnter',
    cond = function()
      local has_variant = statusline.variant == 'heirline'
        or statuscolumn.variant == 'heirline'
      local condition = statusline.enable and has_variant
      return ar.get_plugin_cond('heirline.nvim', condition)
    end,
    init = function()
      ar.augroup('Heirline', {
        event = 'ColorScheme',
        command = function(arg)
          if not ar.has('heirline.nvim') then return end
          local theming = require('ar.theming')
          local utils = require('heirline.utils')
          utils.on_colorscheme(theming.get_statusline_palette(arg.match))
        end,
      })
    end,
    config = function(_, opts) require('heirline').setup(opts) end,
  },
}
