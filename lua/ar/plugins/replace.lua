local minimal = ar.plugins.minimal

return {
  ------------------------------------------------------------------------------
  -- Find And Replace
  {
    'MagicDuck/grug-far.nvim',
    cond = function() return ar.get_plugin_cond('grug-far.nvim', not minimal) end,
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
    cond = function() return ar.get_plugin_cond('muren.nvim', not minimal) end,
    cmd = { 'MurenToggle', 'MurenUnique', 'MurenFresh' },
    opts = {},
  },
  {
    'gbprod/substitute.nvim',
    cond = function() return ar.get_plugin_cond('substitute.nvim', not minimal) end,
    keys = {
      { 'cx', "<cmd>lua require('substitute').operator()<cr>", mode = 'n' },
      { 'cx', "<cmd>lua require('substitute').visual()<cr>", mode = 'x' },
      { 'cxc', "<cmd>lua require('substitute').line()<cr>", mode = 'n' },
      { 'cX', "<cmd>lua require('substitute').eol()<cr>", mode = 'n' },
    },
    opts = {},
  },
}
