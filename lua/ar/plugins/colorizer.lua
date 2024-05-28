return {
  {
    'brenoprata10/nvim-highlight-colors',
    event = { 'BufRead' },
    cmd = { 'HighlightColors' },
    opts = {
      render = 'virtual',
      enable_tailwind = true,
    },
  },
  {
    'uga-rosa/ccc.nvim',
    cmd = { 'CccHighlighterToggle', 'CccHighlighterEnable', 'CccPick' },
    opts = function()
      local ccc = require('ccc')
      local p = ccc.picker
      p.hex.pattern = {
        [=[\v%(^|[^[:keyword:]])\zs#(\x\x)(\x\x)(\x\x)>]=],
        [=[\v%(^|[^[:keyword:]])\zs#(\x\x)(\x\x)(\x\x)(\x\x)>]=],
      }
      ccc.setup({
        win_opts = { border = rvim.ui.current.border },
        pickers = {
          p.hex,
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
