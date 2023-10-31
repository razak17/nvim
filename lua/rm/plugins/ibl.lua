local left_thin_block = rvim.ui.icons.separators.left_thin_block

return {
  'lukas-reineke/indent-blankline.nvim',
  cond = rvim.treesitter.enable and false,
  event = 'UIEnter',
  main = 'ibl',
  opts = {
    indent = {
      char = left_thin_block,
      tab_char = left_thin_block,
      highlight = 'IndentBlanklineChar',
    },
    scope = {
      char = left_thin_block,
      show_start = false,
      show_end = false,
      include = {
        node_type = {
          ['*'] = { '*' },
        },
      },
      highlight = { 'IndentBlanklineContextChar' },
    },
    exclude = {
      buftypes = { 'nofile', 'terminal' },
      filetypes = {
        'aerial',
        'alpha',
        'dbout',
        'flutterToolsOutline',
        'git',
        'gitcommit',
        'help',
        'lazy',
        'log',
        'markdown',
        'neogitstatus',
        'neo-tree',
        'neo-tree-popup',
        'norg',
        'org',
        'orgagenda',
        'startify',
        'txt',
        'Trouble',
        'undotree',
      },
    },
  },
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
}
