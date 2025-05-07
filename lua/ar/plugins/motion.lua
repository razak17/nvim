local minimal = ar.plugins.minimal

return {
  {
    'razak17/accelerated-jk.nvim',
    cond = not ar.plugin_disabled('accelerated-jk.nvim'),
    event = 'VeryLazy',
    -- stylua: ignore
    keys = {
      { 'j', "<Cmd>lua require'accelerated-jk'.command('gj')<CR>", mode = { 'x', 'n' }, },
      { 'k', "<Cmd>lua require'accelerated-jk'.command('gk')<CR>", mode = { 'x', 'n' }, },
    },
  },
  {
    'aaronik/treewalker.nvim',
    event = 'VeryLazy',
    cmd = { 'Treewalker' },
    cond = not minimal,
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
    init = function()
      map({ 'n', 'x', 'o' }, ';n', require('demicolon.repeat_jump').forward)
      map({ 'n', 'x', 'o' }, ';p', require('demicolon.repeat_jump').backward)
    end,
    keys = { ';', ']', '[' },
    dependencies = 'nvim-treesitter/nvim-treesitter-textobjects',
    opts = {
      keymaps = { horizontal_motions = false, repeat_motions = false },
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
    init = function()
      ar.add_to_select_menu(
        'toggle',
        { ['Toggle Precognition'] = 'Precognition toggle' }
      )
    end,
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
