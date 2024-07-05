local separators = ar.ui.icons.separators
local minimal = ar.plugins.minimal

return {
  'echasnovski/mini.hipatterns',
  {
    'echasnovski/mini.icons',
    opts = {},
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
  },
  {
    'echasnovski/mini.indentscope',
    cond = not ar.plugins.minimal and ar.plugins.niceties,
    event = 'BufRead',
    opts = {
      symbol = separators.left_thin_block,
      draw = { delay = 100 },
      -- stylua: ignore
      filetype_exclude = {
        'lazy', 'fzf', 'alpha', 'dbout', 'neo-tree-popup', 'log', 'gitcommit',
        'txt', 'help', 'NvimTree', 'git', 'flutterToolsOutline', 'undotree',
        'markdown', 'norg', 'org', 'orgagenda',
        '', -- for all buffers without a file type
      },
    },
    config = function(_, opts)
      ar.highlight.plugin('mini-indentscope', {
        theme = {
          -- stylua: ignore
          ['onedark'] = {
            { MiniIndentscopeSymbol = { link = 'IndentBlanklineContextChar' } },
            { MiniIndentscopeSymbolOff = { link = 'IndentBlanklineChar' } },
          },
        },
      })
      require('mini.indentscope').setup(opts)
    end,
  },
  { 'echasnovski/mini.misc', opts = {} },
  {
    'echasnovski/mini.bracketed',
    cond = not ar.plugins.minimal,
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'echasnovski/mini.animate',
    cond = not ar.plugins.minimal and false,
    event = 'VeryLazy',
    opts = {},
  },
  {
    'echasnovski/mini.trailspace',
    -- stylua: ignore
    keys = {
      { '<leader>wx', '<Cmd>lua MiniTrailspace.trim()<CR>', desc = 'trailspace: trim all', },
      { '<leader>wl', '<Cmd>lua MiniTrailspace.trim_last_lines()<CR>', desc = 'trailspace: trim last lines', },
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
      'ds',
      { 'ym', desc = 'add surrounding' },
      { 'yo', desc = 'replace surrounding' },
    },
    config = function()
      require('mini.surround').setup({
        mappings = {
          add = 'ym',
          delete = 'ds',
          find = 'yf',
          find_left = 'yF',
          highlight = 'yh',
          replace = 'yo',
          update_n_lines = 'yn',
        },
      })
    end,
  },
  {
    'echasnovski/mini.diff',
    event = { 'BufRead', 'BufNewFile' },
    cond = false,
    opts = {},
  },
  {
    'echasnovski/mini.move',
    cond = not minimal and false,
    event = 'VeryLazy',
    opts = {
      mappings = {
        -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
        left = '<M-h>',
        right = '<M-l>',
        down = '<M-j>',
        up = '<M-k>',
        -- Move current line in Normal mode
        line_left = '<M-h>',
        line_right = '<M-/>',
        line_down = '<M-j>',
        line_up = '<M-k>',
      },
    },
  },
  {
    'echasnovski/mini.pairs',
    cond = minimal,
    event = 'VeryLazy',
    opts = {
      mappings = {
        ['`'] = {
          action = 'closeopen',
          pair = '``',
          neigh_pattern = '[^\\`].',
          register = { cr = false },
        },
      },
    },
  },
  {
    'echasnovski/mini.comment',
    cond = false,
    event = 'VeryLazy',
    opts = {
      options = {
        custom_commentstring = function()
          return require('ts_context_commentstring.internal').calculate_commentstring()
            or vim.bo.commentstring
        end,
      },
    },
  },
}
