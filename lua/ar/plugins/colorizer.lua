local minimal = rvim.plugins.minimal

return {
  {
    'brenoprata10/nvim-highlight-colors',
    cond = not minimal,
    event = { 'BufRead' },
    cmd = { 'HighlightColors' },
    opts = {
      render = 'virtual',
      enable_tailwind = true,
    },
  },
  {
    'uga-rosa/ccc.nvim',
    cond = not minimal,
    cmd = { 'CccHighlighterToggle', 'CccHighlighterEnable', 'CccPick' },
    config = function()
      local ccc = require('ccc')
      local p = ccc.picker
      ccc.setup({
        win_opts = { border = rvim.ui.current.border },
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
          auto_enable = true,
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
}
