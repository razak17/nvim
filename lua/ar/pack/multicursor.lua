ar.pack.add({
  {
    src = 'https://github.com/jake-stewart/multicursor.nvim',
    cond = function()
      return ar.get_plugin_cond('multicursor.nvim', not ar.plugins.minimal)
    end,
    event = 'VeryLazy',
    setup = function()
      local mc = require('multicursor-nvim')
      mc.setup()
      map({ 'n', 'v' }, '<M-e>', function() mc.matchAddCursor(1) end)
      map({ 'n', 'v' }, '<M-f>', function() mc.matchSkipCursor(1) end)
      map('n', '<esc>', function()
        if mc.cursorsEnabled() then mc.clearCursors() end
      end)
      ar.highlight.plugin('multicursor', {
        theme = {
          ['onedark'] = {
            {
              MultiCursorCursor = {
                bg = { from = 'Special', attr = 'fg' },
                fg = { from = 'Comment' },
              },
            },
          },
        },
      })
    end,
  },
})
