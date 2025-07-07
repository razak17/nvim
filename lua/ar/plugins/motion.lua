local minimal = ar.plugins.minimal

return {
  {
    'aaronik/treewalker.nvim',
    event = 'VeryLazy',
    cmd = { 'Treewalker' },
    cond = function() return ar.get_plugin_cond('treewalker.nvim', not minimal) end,
    keys = {
      -- { mode = { 'n', 'v' }, '<C-h>', '<Cmd>Treewalker Left<cr>' },
      { mode = { 'n', 'v' }, '<A-j>', '<Cmd>Treewalker Down<cr>' },
      { mode = { 'n', 'v' }, '<A-k>', '<Cmd>Treewalker Up<cr>' },
      -- { mode = { 'n', 'v' }, '<C-l>', '<Cmd>Treewalker Right<cr>' },
      { mode = { 'n', 'v' }, '<A-S-h>', '<Cmd>Treewalker SwapLeft<cr>' },
      { mode = { 'n', 'v' }, '<A-S-j>', '<Cmd>Treewalker SwapDown<cr>' },
      { mode = { 'n', 'v' }, '<A-S-k>', '<Cmd>Treewalker SwapUp<cr>' },
      { mode = { 'n', 'v' }, '<A-S-l>', '<Cmd>Treewalker SwapRight<cr>' },
    },
    opts = {},
  },
  {
    'mawkler/demicolon.nvim',
    cond = not minimal and ar.treesitter.enable,
    -- stylua: ignore
    init = function()
      map({ 'n', 'x', 'o' }, ';n', function () require('demicolon.repeat_jump').forward() end, { desc = 'demicolon: forward' })
      map({ 'n', 'x', 'o' }, ';p', function () require('demicolon.repeat_jump').backward() end, { desc = 'demicolon: backward' })
    end,
    keys = { ';', ']', '[' },
    dependencies = 'nvim-treesitter/nvim-treesitter-textobjects',
    opts = {
      keymaps = { horizontal_motions = false, repeat_motions = false },
    },
  },
  {
    'chrisgrieser/nvim-spider',
    cond = not ar.plugins.minimal and ar.plugins.niceties,
    -- stylua: ignore
    keys = {
      { 'w', "<cmd>lua require('spider').motion('w')<CR>", mode = { 'x', 'n', 'o' }, },
      { 'e', "<cmd>lua require('spider').motion('e')<CR>", mode = { 'x', 'n', 'o' }, },
      { 'b', "<cmd>lua require('spider').motion('b')<CR>", mode = { 'x', 'n', 'o' }, },
      { 'ge', "<cmd>lua require('spider').motion('ge')<CR>", mode = { 'x', 'n', 'o' }, },
    },
  },
}
