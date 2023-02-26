local hl = rvim.highlight

return {
  'nvim-tree/nvim-web-devicons',

  { 'fladson/vim-kitty', ft = 'kitty' },

  { 'razak17/zephyr-nvim', lazy = false, priority = 1000 },

  {
    'itchyny/vim-highlighturl',
    event = 'BufReadPre',
    config = function() vim.g.highlighturl_guifg = hl.get('URL', 'fg') end,
  },

  {
    'romainl/vim-cool',
    event = 'BufReadPre',
    config = function() vim.g.CoolTotalMatches = 1 end,
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      char = '▏', -- ┆ ┊ ▎
      show_foldtext = false,
      context_char = '▏', -- ▎
      char_priority = 12,
      show_current_context = true,
      show_current_context_start = false,
      show_current_context_start_on_current_line = false,
      show_first_indent_level = true,
      filetype_exclude = {
        'neo-tree-popup',
        'dap-repl',
        'startify',
        'dashboard',
        'log',
        'fugitive',
        'gitcommit',
        'packer',
        'vimwiki',
        'markdown',
        'txt',
        'vista',
        'help',
        'NvimTree',
        'git',
        'TelescopePrompt',
        'undotree',
        'flutterToolsOutline',
        'norg',
        'org',
        'orgagenda',
        'dbout',
        '', -- for all buffers without a file type
      },
      buftype_exclude = { 'terminal', 'nofile' },
    },
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
      hl.plugin('Headlines', {
        theme = {
          ['*'] = {
            { Dash = { background = '#0b60a1', bold = true } },
          },
          ['horizon'] = {
            {
              Headline = {
                bold = true,
                italic = true,
                background = { from = 'Normal', alter = 20 },
              },
            },
            {
              Headline1 = {
                inherit = 'Headline',
                fg = { from = 'Type' },
              },
            },
          },
        },
      })
      require('headlines').setup({
        markdown = { headline_highlights = { 'Headline1' } },
        org = { headline_highlights = false },
        norg = { codeblock_highlight = false },
      })
    end,
  },

  {
    'folke/todo-comments.nvim',
    event = 'BufReadPre',
    cmd = { 'TodoTelescope', 'TodoTrouble', 'TodoQuickFix', 'TodoDots' },
    keys = {
      { '<leader>tt', '<cmd>TodoDots<CR>', desc = 'todo: dotfiles todos' },
      {
        '<leader>tj',
        function() require('todo-comments').jump_next() end,
        desc = 'todo-comments: next todo',
      },
      {
        '<leader>tk',
        function() require('todo-comments').jump_prev() end,
        desc = 'todo-comments: prev todo',
      },
    },
    config = function()
      require('todo-comments').setup({ highlight = { after = '' } })
      rvim.command(
        'TodoDots',
        string.format('TodoTelescope cwd=%s keywords=TODO,FIXME', rvim.get_config_dir())
      )
    end,
  },

  {
    'lukas-reineke/virt-column.nvim',
    event = 'BufReadPre',
    opts = { char = '▕' },
    init = function()
      hl.plugin('virt_column', { { VirtColumn = { link = 'FloatBorder' } } })
      rvim.augroup('VirtCol', {
        {
          event = { 'BufEnter', 'WinEnter' },
          command = function(args)
            rvim.ui.decorations.set_colorcolumn(
              args.buf,
              function(virtcolumn) require('virt-column').setup_buffer({ virtcolumn = virtcolumn }) end
            )
          end,
        },
      })
    end,
  },

  {
    'uga-rosa/ccc.nvim',
    keys = { { '<leader>oc', '<cmd>CccHighlighterToggle<CR>', desc = 'toggle ccc' } },
    opts = {
      win_opts = { border = rvim.ui.current.border },
      highlighter = { auto_enable = true, excludes = { 'dart', 'html', 'css', 'typescriptreact' } },
    },
  },

  {
    'm-demare/hlargs.nvim',
    init = function()
      hl.plugin('hlargs', {
        theme = {
          ['*'] = { { Hlargs = { italic = true, foreground = '#A5D6FF' } } },
        },
      })
      require('hlargs').setup({
      excluded_filetypes = { 'buffer_manager' },
        excluded_argnames = {
          declarations = { 'use', '_' },
          usages = { go = { '_' }, lua = { 'self', 'use', '_' } },
        },
      })
    end,
  },

  {
    'zbirenbaum/neodim',
    event = 'VeryLazy',
    enabled = false,
    opts = {
      blend_color = hl.get('Normal', 'bg'),
      hide = { underline = false },
    },
  },
}
