local minimal = ar.plugins.minimal

return {
  {
    'catgoose/nvim-colorizer.lua',
    cond = function() return ar.get_plugin_cond('nvim-colorizer.lua') end,
    config = function() require('colorizer').setup() end,
    cmd = {
      'ColorizerAttachToBuffer',
      'ColorizerDetachFromBuffer',
      'ColorizerReloadAllBuffers',
      'ColorizerToggle',
    },
    init = function()
      ar.add_to_select_menu(
        'toggle',
        { ['Toggle Colorizer'] = 'ColorizerToggle' }
      )
    end,
  },
  {
    'uga-rosa/ccc.nvim',
    cond = function() return ar.get_plugin_cond('ccc.nvim', not minimal) end,
    cmd = { 'CccHighlighterToggle', 'CccHighlighterEnable', 'CccPick' },
    init = function()
      ar.add_to_select_menu('toggle', {
        ['Toggle Ccc'] = 'CccHighlighterToggle',
        ['Toggle Pick'] = 'CccPick',
      })
    end,
    config = function()
      local ccc = require('ccc')
      local p = ccc.picker
      ccc.setup({
        win_opts = { border = ar.ui.current.border.default },
        pickers = {
          p.hex_long,
          p.css_rgb,
          p.css_hsl,
          p.css_hwb,
          p.css_lab,
          p.css_lch,
          p.css_oklab,
          p.css_oklch,
        },
        highlighter = {
          auto_enable = false,
          excludes = {
            'dart',
            'lazy',
            'orgagenda',
            'org',
            'NeogitStatus',
            'toggleterm',
          },
        },
      })
    end,
  },
  {
    'cjodo/convert.nvim',
    cond = function() return ar.get_plugin_cond('convert.nvim', not minimal) end,
    cmd = { 'ConvertFindNext', 'ConvertFindCurrent' },
  },
  {
    'eero-lehtinen/oklch-color-picker.nvim',
    cond = function()
      return ar.get_plugin_cond('oklch-color-picker.nvim', not minimal)
    end,
    init = function()
      ar.add_to_select_menu('toggle', {
        ['Toggle Color Picker'] = "lua require('oklch-color-picker').pick_under_cursor()",
      })
    end,
    opts = {},
  },
}
