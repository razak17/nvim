local minimal = ar.plugins.minimal
local ui, highlight = ar.ui, ar.highlight
local separators = ui.icons.separators
local left_thin_block = ui.icons.separators.left_thin_block
local indentline_enable = ar_config.ui.indentline.enable
local indentline_variant = ar_config.ui.indentline.variant

return {
  {
    'nvimdev/indentmini.nvim',
    cond = function()
      return not minimal
        and indentline_enable
        and indentline_variant == 'indentmini'
    end,
    event = 'UIEnter',
    opts = {
      char = separators.left_thin_block,
      only_current = true,
      -- stylua: ignore
      exclude = {
        'aerial', 'alpha', 'dbout', 'flutterToolsOutline', 'git', 'gitcommit', 'help',
        'lazy', 'log', 'markdown', 'neogitstatus', 'neo-tree', 'neo-tree-popup', 'norg',
        'org', 'orgagenda', 'snacks_dashboard', 'startify', 'txt', 'Trouble', 'undotree',
      },
    },
    config = function(_, opts)
      ar.highlight.plugin('indentmini', {
        theme = {
          ['onedark'] = {
            { IndentLineCurrent = { link = 'IndentBlanklineContextChar' } },
            { IndentLine = { link = 'IndentBlanklineChar' } },
          },
        },
      })
      require('indentmini').setup(opts)
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    cond = function()
      return not minimal and indentline_enable and indentline_variant == 'ibl'
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
        -- stylua: ignore
        filetypes = {
          'aerial', 'alpha', 'dbout', 'flutterToolsOutline', 'git', 'gitcommit', 'help',
          'lazy', 'log', 'markdown', 'neogitstatus', 'neo-tree', 'neo-tree-popup', 'norg',
          'org', 'orgagenda', 'snacks_dashboard', 'startify', 'txt', 'Trouble', 'undotree',
        },
      },
    },
  },
  {
    'shellRaining/hlchunk.nvim',
    enabled = false,
    cond = not minimal and false,
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
