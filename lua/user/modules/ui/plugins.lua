local hl = rvim.highlight
local ui = rvim.ui

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
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
    config = function()
      -- NOTE: the limit is half the max lines because this is the cursor theme so
      -- unless the cursor is at the top or bottom it realistically most often will
      -- only have half the screen available
      local function get_height(self, _, max_lines)
        local results = #self.finder.results
        local PADDING = 4 -- this represents the size of the telescope window
        local LIMIT = math.floor(max_lines / 2)
        return (results <= (LIMIT - PADDING) and results + PADDING or LIMIT)
      end

      require('dressing').setup({
        input = {
          insert_only = false,
          border = rvim.ui.current.border,
          win_options = { winblend = 2 },
        },
        select = {
          get_config = function()
            return {
              backend = 'telescope',
              telescope = require('telescope.themes').get_cursor({
                layout_config = { height = get_height },
                borderchars = rvim.ui.border.ui_select,
              }),
            }
          end,
          telescope = require('telescope.themes').get_dropdown({
            layout_config = { height = get_height },
          }),
        },
      })
    end,
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
  { 'LunarVim/horizon.nvim', lazy = false, priority = 1000 },

  {
    'lukas-reineke/headlines.nvim',
    ft = { 'org', 'norg', 'markdown', 'yaml' },
    config = function()
      hl.plugin('Headlines', {
        { Headline1 = { background = '#003c30' } },
        { Headline2 = { background = '#00441b' } },
        { Headline3 = { background = '#084081' } },
        { Dash = { background = '#0b60a1', bold = true } },
        {
          CodeBlock = {
            bold = true,
            italic = true,
            background = { from = 'Normal', alter = 30 },
          },
        },
      })
      require('headlines').setup({
        org = { headline_highlights = false },
        norg = { headline_highlights = { 'Headline' }, codeblock_highlight = false },
        markdown = { headline_highlights = { 'Headline1' } },
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
            ui.decorations.set_colorcolumn(
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
      win_opts = { border = ui.current.border },
      highlighter = { auto_enable = true, excludes = { 'dart', 'html', 'css', 'typescriptreact' } },
    },
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
