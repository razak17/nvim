local separators = rvim.ui.icons.separators

return {
  {
    'razak17/mini.indentscope',
    -- enabled = not rvim.plugins.minimal,
    enabled = false,
    event = 'BufRead',
    version = false,
    init = function()
      rvim.highlight.plugin('mini-indentscope', {
        { MiniIndentscopeSymbol = { inherit = 'IndentBlanklineContextChar' } },
        { MiniIndentscopeSymbolOff = { inherit = 'IndentBlanklineChar' } },
      })
    end,
    opts = {
      symbol = separators.left_thin_block,
      draw = { delay = 200 },
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
  },
  { 'echasnovski/mini.misc', opts = {} },
  {
    'echasnovski/mini.bracketed',
    enabled = not rvim.plugins.minimal,
    event = 'VeryLazy',
    opts = {},
  },
  {
    'echasnovski/mini.animate',
    enabled = false,
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
    enabled = false,
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'echasnovski/mini.ai',
    enabled = rvim.treesitter.enable,
    event = 'VeryLazy',
    config = function()
      require('mini.ai').setup({
        mappings = { around_last = '', inside_last = '' },
      })
    end,
  },
  {
    'echasnovski/mini.files',
    keys = {
      { '<leader>e', '<cmd>lua MiniFiles.open()<CR>', desc = 'mini.files' },
    },
    opts = {},
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
