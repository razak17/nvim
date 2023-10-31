local separators = rvim.ui.icons.separators

return {
  {
    'razak17/mini.indentscope',
    event = 'BufRead',
    opts = {
      symbol = separators.left_thin_block,
      draw = { delay = 100 },
      filetype_exclude = {
        'lazy',
        'fzf',
        'alpha',
        'dbout',
        'neo-tree-popup',
        'log',
        'gitcommit',
        'txt',
        'help',
        'NvimTree',
        'git',
        'flutterToolsOutline',
        'undotree',
        'markdown',
        'norg',
        'org',
        'orgagenda',
        '', -- for all buffers without a file type
      },
    },
    init = function()
      rvim.highlight.plugin('mini-indentscope', {
        { MiniIndentscopeSymbol = { inherit = 'IndentBlanklineContextChar' } },
        { MiniIndentscopeSymbolOff = { inherit = 'IndentBlanklineChar' } },
      })
    end,
  },
  { 'echasnovski/mini.misc', opts = {} },
  {
    'echasnovski/mini.bracketed',
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'echasnovski/mini.animate',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'echasnovski/mini.trailspace',
    keys = {
      {
        '<leader>wx',
        '<Cmd>lua MiniTrailspace.trim()<CR>',
        desc = 'trailspace: trim all',
      },
      {
        '<leader>wl',
        '<Cmd>lua MiniTrailspace.trim_last_lines()<CR>',
        desc = 'trailspace: trim last lines',
      },
    },
    opts = {},
  },
  {
    'echasnovski/mini.cursorword',
    cond = false,
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'echasnovski/mini.ai',
    event = { 'BufRead', 'BufNewFile' },
    config = function()
      require('mini.ai').setup({
        mappings = { around_last = '', inside_last = '' },
      })
    end,
  },
  {
    'echasnovski/mini.surround',
    keys = {
      { 'ys', desc = 'add surrounding' },
      'ds',
      { 'yr', desc = 'delete surrounding' },
    },
    config = function()
      require('mini.surround').setup({
        mappings = {
          add = 'ys',
          delete = 'ds',
          find = 'yf',
          find_left = 'yF',
          highlight = 'yh',
          replace = 'yr',
          update_n_lines = 'yn',
        },
      })
    end,
  },
}
