local minimal = ar.plugins.minimal

return {
  {
    'yutkat/wb-only-current-line.nvim',
    cond = not minimal,
    event = 'VeryLazy',
  },
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
    'razak17/demicolon.nvim',
    cond = not minimal,
    lazy = false,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    opts = {
      keymaps = {
        horizontal_motions = false,
        diagnostic_motions = false,
        repeat_motions = true,
      },
      integrations = {
        gitsigns = { enabled = false },
      },
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
    cmd = { 'Precognition' },
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
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
