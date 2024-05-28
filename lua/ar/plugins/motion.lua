return {
  {
    'razak17/accelerated-jk.nvim',
    event = 'VeryLazy',
    -- stylua: ignore
    keys = {
      { 'j', "<cmd>lua require'accelerated-jk'.command('gj')<CR>", mode = { 'x', 'n' }, },
      { 'k', "<cmd>lua require'accelerated-jk'.command('gk')<CR>", mode = { 'x', 'n' }, },
    },
  },
  {
    'm4xshen/hardtime.nvim',
    cond = false,
    event = 'VeryLazy',
    opts = {
      disabled_filetypes = {
        'qf',
        'neo-tree',
        'lazy',
        'mason',
        'NeogitStatus',
        'lspinfo',
        'null-ls-info',
      },
    },
  },
  {
    'tris203/precognition.nvim',
    cond = false,
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'chrisgrieser/nvim-spider',
    cond = not rvim.plugins.minimal and rvim.plugins.niceties,
    -- stylua: ignore
    keys = {
      { 'w', "<cmd>lua require('spider').motion('w')<CR>", mode = { 'x', 'n', 'o' }, },
      { 'e', "<cmd>lua require('spider').motion('e')<CR>", mode = { 'x', 'n', 'o' }, },
      { 'b', "<cmd>lua require('spider').motion('b')<CR>", mode = { 'x', 'n', 'o' }, },
      { 'ge', "<cmd>lua require('spider').motion('ge')<CR>", mode = { 'x', 'n', 'o' }, },
    },
  },
}
