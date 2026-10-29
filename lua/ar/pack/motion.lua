ar.pack.add({
  {
    src = 'https://github.com/aaronik/treewalker.nvim',
    event = 'VeryLazy',
    cmd = { 'Treewalker' },
    cond = function()
      return ar.get_plugin_cond('treewalker.nvim', not ar.plugins.minimal)
    end,
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
    setup = function() require('treewalker').setup() end,
  },
  {
    src = 'https://github.com/chrisgrieser/nvim-spider',
    cond = function()
      local condition = not ar.plugins.minimal and ar.plugins.niceties
      return ar.get_plugin_cond('nvim-spider', condition)
    end,
    keys = {
      {
        'w',
        "<cmd>lua require('spider').motion('w')<CR>",
        mode = { 'x', 'n', 'o' },
      },
      {
        'e',
        "<cmd>lua require('spider').motion('e')<CR>",
        mode = { 'x', 'n', 'o' },
      },
      {
        'b',
        "<cmd>lua require('spider').motion('b')<CR>",
        mode = { 'x', 'n', 'o' },
      },
      {
        'ge',
        "<cmd>lua require('spider').motion('ge')<CR>",
        mode = { 'x', 'n', 'o' },
      },
    },
  },
})
