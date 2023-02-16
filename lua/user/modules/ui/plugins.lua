return {
  'nvim-tree/nvim-web-devicons',
  { 'fladson/vim-kitty', ft = 'kitty' },
  { 'razak17/zephyr-nvim', lazy = false, priority = 1000 },
  { 'itchyny/vim-highlighturl', event = 'BufReadPre' },

  {
    'romainl/vim-cool',
    event = 'BufReadPre',
    config = function() vim.g.CoolTotalMatches = 1 end,
  },

  {
    'j-hui/fidget.nvim',
    event = 'BufReadPre',
    config = function()
      require('fidget').setup({
        align = { bottom = false, right = true },
        fmt = { stack_upwards = false },
      })
      rvim.augroup('CloseFidget', {
        {
          event = { 'VimLeavePre', 'LspDetach' },
          command = 'silent! FidgetClose',
        },
      })
    end,
  },

  {
    'lukas-reineke/headlines.nvim',
    ft = { 'org', 'norg', 'markdown', 'yaml' },
    config = function()
      require('headlines').setup({
        markdown = {
          headline_highlights = { 'Headline1', 'Headline2', 'Headline3' },
        },
        org = { headline_highlights = false },
        norg = { codeblock_highlight = false },
      })
      rvim.highlight.plugin('Headlines', {
        { Headline1 = { background = '#003c30', foreground = 'White' } },
        { Headline2 = { background = '#00441b', foreground = 'White' } },
        { Headline3 = { background = '#084081', foreground = 'White' } },
        { Dash = { background = '#0b60a1', bold = true } },
      })
    end,
  },

  {
    'folke/todo-comments.nvim',
    event = 'BufReadPre',
    cmd = { 'TodoTelescope', 'TodoTrouble', 'TodoQuickFix', 'TodoDots' },
    init = function()
      rvim.nnoremap(
        '<leader>tj',
        function() require('todo-comments').jump_next() end,
        'todo-comments: next todo'
      )
      rvim.nnoremap(
        '<leader>tk',
        function() require('todo-comments').jump_prev() end,
        'todo-comments: prev todo'
      )
    end,
    config = function()
      require('todo-comments').setup({ highlight = { after = '' } })
      rvim.command(
        'TodoDots',
        string.format('TodoTelescope cwd=%s keywords=TODO,FIXME', rvim.get_config_dir())
      )
      rvim.nnoremap('<leader>tt', '<cmd>TodoDots<CR>', 'todo: dotfiles todos')
    end,
  },

  {
    'lukas-reineke/virt-column.nvim',
    event = 'VeryLazy',
    config = function()
      rvim.highlight.plugin('virt_column', {
        { VirtColumn = { bg = 'None', fg = { from = 'VertSplit' } } },
      })
      require('virt-column').setup({ char = '│' })
    end,
  },

  {
    'uga-rosa/ccc.nvim',
    keys = { { '<leader>oc', '<cmd>CccHighlighterToggle<CR>', desc = 'toggle ccc' } },
    opts = {
      win_opts = { border = rvim.ui.current.border },
      highlighter = {
        auto_enable = true,
        excludes = { 'dart', 'html', 'css', 'typescriptreact' },
      },
    },
  },

  {
    'm-demare/hlargs.nvim',
    event = 'VeryLazy',
    config = function()
      rvim.highlight.plugin('hlargs', {
        theme = {
          ['*'] = { { Hlargs = { italic = true, foreground = '#A5D6FF' } } },
        },
      })
      require('hlargs').setup({
        excluded_argnames = {
          declarations = { 'use', 'use_rocks', '_' },
          usages = {
            go = { '_' },
            lua = { 'self', 'use', 'use_rocks', '_' },
          },
        },
      })
    end,
  },

  {
    'zbirenbaum/neodim',
    event = 'VeryLazy',
    enabled = false,
    opts = {
      blend_color = rvim.highlight.get('Normal', 'bg'),
      hide = { underline = false },
    },
  },
}
