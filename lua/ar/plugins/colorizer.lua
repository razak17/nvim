local minimal = ar.plugins.minimal

return {
  {
    'catgoose/nvim-colorizer.lua',
    config = function() require('colorizer').setup() end,
    cmd = {
      'ColorizerAttachToBuffer',
      'ColorizerDetachFromBuffer',
      'ColorizerReloadAllBuffers',
      'ColorizerToggle',
    },
    init = function()
      ar.add_to_menu('toggle', { ['Toggle Colorizer'] = 'ColorizerToggle' })
    end,
  },
  {
    'brenoprata10/nvim-highlight-colors',
    cond = not minimal,
    cmd = { 'HighlightColors' },
    init = function()
      ar.add_to_menu('toggle', { ['Toggle Colors'] = 'HighlightColors Toggle' })
    end,
    opts = {
      render = 'virtual',
      enable_tailwind = true,
    },
  },
  {
    'uga-rosa/ccc.nvim',
    cond = not minimal,
    cmd = { 'CccHighlighterToggle', 'CccHighlighterEnable', 'CccPick' },
    init = function()
      ar.add_to_menu('toggle', {
        ['Toggle Ccc'] = 'CccHighlighterToggle',
        ['Toggle Pick'] = 'CccPick',
      })
    end,
    config = function()
      local ccc = require('ccc')
      local p = ccc.picker
      ccc.setup({
        win_opts = { border = ar.ui.current.border },
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
    cond = not minimal,
    cmd = { 'ConvertFindNext', 'ConvertFindCurrent' },
  },
  {
    'eero-lehtinen/oklch-color-picker.nvim',
    init = function()
      ar.add_to_menu('toggle', {
        ['Toggle Color Picker'] = "lua require('oklch-color-picker').pick_under_cursor()",
      })
    end,
    opts = {},
  },
}
