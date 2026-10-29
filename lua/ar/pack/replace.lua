local minimal = ar.plugins.minimal

ar.pack.add({
  {
    src = 'https://github.com/MagicDuck/grug-far.nvim',
    cond = function() return ar.get_plugin_cond('grug-far.nvim', not minimal) end,
    cmd = { 'GrugFar', 'GrugFarWithin' },
    init = function()
      ar.add_to_select(
        'command_palette',
        { ['Search And Replace'] = 'GrugFar' }
      )
    end,
    setup = function()
      require('grug-far').setup({
        startInInsertMode = false,
        transient = false,
        keymaps = {
          replace = '<C-[>',
          qflist = '<C-q>',
          gotoLocation = '<enter>',
          close = '<C-x>',
        },
      })
    end,
  },
  {
    src = 'https://github.com/AckslD/muren.nvim',
    cond = function() return ar.get_plugin_cond('muren.nvim', not minimal) end,
    cmd = { 'MurenToggle', 'MurenUnique', 'MurenFresh' },
    setup = function() require('muren').setup() end,
  },
  {
    src = 'https://github.com/gbprod/substitute.nvim',
    cond = function() return ar.get_plugin_cond('substitute.nvim', not minimal) end,
    keys = {
      { 'cx', "<cmd>lua require('substitute').operator()<cr>", mode = 'n' },
      { 'cx', "<cmd>lua require('substitute').visual()<cr>", mode = 'x' },
      { 'cxc', "<cmd>lua require('substitute').line()<cr>", mode = 'n' },
      { 'cX', "<cmd>lua require('substitute').eol()<cr>", mode = 'n' },
    },
    setup = function() require('substitute').setup() end,
  },
})
