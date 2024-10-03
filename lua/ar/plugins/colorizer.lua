local minimal = ar.plugins.minimal

return {
  { 'nvchad/volt' },
  {
    'nvchad/minty',
    cond = not minimal,
    init = function()
      ar.add_to_menu('toggle', {
        ['Toggle Color Picker'] = function()
          -- For border or without border
          require('minty.huefy').open({ border = false })
          -- add border=false for flat look on shades window
        end,
      })
    end,
    keys = {
      {
        '<leader>oP',
        '<Cmd>lua require("minty.huefy").open( { border = true } )<CR>',
        desc = 'toggle minty',
      },
    },
    config = function()
      require('minty.huefy').open()
      require('minty.shades').open()
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
}
