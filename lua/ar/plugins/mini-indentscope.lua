local separators = ar.ui.icons.separators
local minimal = ar.plugins.minimal

return {
  {
    'nvim-mini/mini.indentscope',
    cond = function()
      local indentline_enable = ar_config.ui.indentline.enable
      local indentline_variant = ar_config.ui.indentline.variant
      return not minimal
        and indentline_enable
        and indentline_variant == 'mini.indentscope'
    end,
    event = 'UIEnter',
    opts = {
      symbol = separators.left_thin_block,
      draw = {
        delay = 100,
        priority = 2,
        animation = function(s, n) return s / n * 20 end,
      },
      -- stylua: ignore
      filetype_exclude = {
        'lazy', 'fzf', 'alpha', 'dbout', 'neo-tree-popup', 'log', 'gitcommit',
        'txt', 'help', 'NvimTree', 'git', 'flutterToolsOutline', 'undotree',
        'markdown', 'norg', 'org', 'orgagenda', 'snacks_dashboard',
        '', -- for all buffers without a file type
      },
    },
    config = function(_, opts)
      ar.highlight.plugin('mini-indentscope', {
        theme = {
          ['onedark'] = {
            { MiniIndentscopeSymbol = { link = 'IndentBlanklineContextChar' } },
            { MiniIndentscopeSymbolOff = { link = 'IndentBlanklineChar' } },
          },
          ['default'] = {
            { MiniIndentscopeSymbol = { link = 'NonText' } },
            { MiniIndentscopeSymbolOff = { link = 'NonText' } },
          },
        },
      })
      require('mini.indentscope').setup(opts)
    end,
  },
}
