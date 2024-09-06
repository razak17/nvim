local minimal = ar.plugins.minimal

return {
  ------------------------------------------------------------------------------
  -- Find And Replace
  {
    'MagicDuck/grug-far.nvim',
    cond = not minimal,
    lazy = false,
    cmd = { 'GrugFar' },
    keys = {
      {
        mode = { 'n', 'v' },
        '<leader>sr',
        function()
          local grug = require('grug-far')
          local ext = vim.bo.buftype == '' and vim.fn.expand('%:e')
          grug.grug_far({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
            },
          })
        end,
        desc = 'grug_far: search and replace',
      },
    },
    opts = {
      startInInsertMode = false,
      transient = false,
      keymaps = {
        replace = '<C-[>',
        qflist = '<C-q>',
        gotoLocation = '<enter>',
        close = '<C-x>',
      },
    },
  },
  {
    'AckslD/muren.nvim',
    cond = not minimal,
    cmd = { 'MurenToggle', 'MurenUnique', 'MurenFresh' },
    opts = {},
  },
}
