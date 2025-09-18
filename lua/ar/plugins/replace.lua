local minimal = ar.plugins.minimal

return {
  ------------------------------------------------------------------------------
  -- Find And Replace
  {
    'MagicDuck/grug-far.nvim',
    cond = not minimal,
    cmd = { 'GrugFar', 'GrugFarWithin' },
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
    init = function()
      ar.add_to_select_menu(
        'command_palette',
        { ['Search And Replace'] = 'GrugFar' }
      )
    end,
  },
  {
    'AckslD/muren.nvim',
    cond = not minimal,
    cmd = { 'MurenToggle', 'MurenUnique', 'MurenFresh' },
    opts = {},
  },
  {
    'gbprod/substitute.nvim',
    cond = not minimal,
    keys = {
      { 'cx', "<cmd>lua require('substitute').operator()<cr>", mode = 'n' },
      { 'cx', "<cmd>lua require('substitute').visual()<cr>", mode = 'x' },
      { 'cxc', "<cmd>lua require('substitute').line()<cr>", mode = 'n' },
      { 'cX', "<cmd>lua require('substitute').eol()<cr>", mode = 'n' },
    },
    opts = {},
  },
}
