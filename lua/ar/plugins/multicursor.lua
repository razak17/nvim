local border = ar.ui.current.border
local minimal = ar.plugins.minimal

return {
  {
    'jake-stewart/multicursor.nvim',
    cond = function() return ar.get_plugin_cond('multicursor.nvim', not minimal) end,
    event = 'VeryLazy',
    config = function()
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
  {
    'smoka7/multicursors.nvim',
    cond = not minimal and false,
    opts = {
      hint_config = { border = border },
    },
    cmd = {
      'MCstart',
      'MCvisual',
      'MCclear',
      'MCpattern',
      'MCvisualPattern',
      'MCunderCursor',
    },
    keys = {
      {
        '<M-e>',
        '<cmd>MCstart<cr>',
        mode = { 'v', 'n' },
        desc = 'Create a selection for selected text or word under the cursor',
      },
    },
  },
}
