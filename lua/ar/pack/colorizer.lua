ar.pack.add({
  {
    src = 'https://github.com/catgoose/nvim-colorizer.lua',
    cond = function() return ar.get_plugin_cond('nvim-colorizer.lua') end,
    setup = function() require('colorizer').setup() end,
    cmd = {
      'ColorizerAttachToBuffer',
      'ColorizerDetachFromBuffer',
      'ColorizerReloadAllBuffers',
      'ColorizerToggle',
    },
    init = function()
      ar.add_to_select('toggle', { ['Toggle Colorizer'] = 'ColorizerToggle' })
    end,
  },
  {
    src = 'https://github.com/uga-rosa/ccc.nvim',
    cond = function()
      return ar.get_plugin_cond('ccc.nvim', not ar.plugins.minimal)
    end,
    cmd = { 'CccHighlighterToggle', 'CccHighlighterEnable', 'CccPick' },
    init = function()
      ar.add_to_select('toggle', {
        ['Toggle Ccc'] = 'CccHighlighterToggle',
        ['Toggle Pick'] = 'CccPick',
      })
    end,
    setup = function()
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
    src = 'https://github.com/cjodo/convert.nvim',
    cond = function()
      return ar.get_plugin_cond('convert.nvim', not ar.plugins.minimal)
    end,
    cmd = { 'ConvertFindNext', 'ConvertFindCurrent' },
  },
  {
    src = 'https://github.com/eero-lehtinen/oklch-color-picker.nvim',
    lazy = false,
    cond = function()
      return ar.get_plugin_cond(
        'oklch-color-picker.nvim',
        not ar.plugins.minimal
      )
    end,
    init = function()
      ar.add_to_select('toggle', {
        ['Toggle Color Picker'] = "lua require('oklch-color-picker').pick_under_cursor()",
      })
    end,

    setup = function() require('oklch-color-picker').setup() end,
  },
})
