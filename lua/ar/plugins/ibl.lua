local minimal = ar.plugins.minimal
local ui, highlight = ar.ui, ar.highlight
local left_thin_block = ui.icons.separators.left_thin_block

return {
  {
    'lukas-reineke/indent-blankline.nvim',
    cond = function()
      return not minimal
        and ar_config.ui.indentline.enable
        and ar_config.ui.indentline.variant == 'ibl'
    end,
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
  },
  {
    'shellRaining/hlchunk.nvim',
    enabled = false,
    cond = not ar.plugins.minimal and false,
    event = 'BufRead',
    config = function()
      require('hlchunk').setup({
        indent = {
          chars = { '▏' },
          style = {
            { fg = highlight.get('IndentBlanklineChar', 'fg') },
          },
        },
        blank = { enable = false },
        chunk = {
          chars = {
            horizontal_line = '─',
            vertical_line = '│',
            left_top = '┌',
            left_bottom = '└',
            right_arrow = '─',
          },
          style = highlight.tint(
            highlight.get('IndentBlanklineContextChar', 'fg'),
            -0.2
          ),
        },
        line_num = {
          style = highlight.get('CursorLineNr', 'fg'),
        },
      })
    end,
  },
}
