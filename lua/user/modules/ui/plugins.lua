local hl = require('user.utils.highlights')

return {
  'nvim-tree/nvim-web-devicons',
  { 'fladson/vim-kitty', lazy = false },
  { 'razak17/zephyr-nvim', lazy = false, priority = 1000 },
  { 'LunarVim/horizon.nvim', lazy = false, priority = 1000 },
  { 'itchyny/vim-highlighturl', event = 'BufReadPre' },

  {
    'romainl/vim-cool',
    event = 'BufReadPre',
    config = function() vim.g.CoolTotalMatches = 1 end,
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
      hl.plugin('Headlines', {
        { Headline1 = { background = '#003c30', foreground = 'White' } },
        { Headline2 = { background = '#00441b', foreground = 'White' } },
        { Headline3 = { background = '#084081', foreground = 'White' } },
        { Dash = { background = '#0b60a1', bold = true } },
      })
    end,
  },

  {
    'SmiteshP/nvim-navic',
    config = function()
      vim.g.navic_silence = true
      local misc = rvim.style.icons.misc
      local icons = rvim.map(function(icon, key)
        hl.set(('NavicIcons%s'):format(key), { link = rvim.lsp.kind_highlights[key] })
        return icon .. ' '
      end, rvim.style.current.lsp_icons)
      require('nvim-navic').setup({
        icons = icons,
        highlight = true,
        depth_limit_indicator = misc.ellipsis,
        separator = (' %s '):format(misc.arrow_right),
      })
      hl.plugin('navic', {
        { NavicText = { bold = false } },
        { NavicSeparator = { link = 'Directory' } },
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
    end,
  },

  {
    'lukas-reineke/virt-column.nvim',
    event = 'VeryLazy',
    config = function()
      hl.plugin('virt_column', {
        { VirtColumn = { bg = 'None', fg = { from = 'VertSplit' } } },
      })
      require('virt-column').setup({ char = '│' })
    end,
  },

  {
    'uga-rosa/ccc.nvim',
    keys = { { '<leader>oc', '<cmd>CccHighlighterToggle<CR>', desc = 'toggle ccc' } },
    config = function()
      require('ccc').setup({
        win_opts = { border = rvim.style.current.border },
        highlighter = {
          auto_enable = true,
          excludes = { 'dart', 'html', 'css', 'typescriptreact' },
        },
      })
    end,
  },

  {
    'm-demare/hlargs.nvim',
    event = 'VeryLazy',
    config = function()
      hl.plugin('hlargs', {
        theme = {
          ['*'] = { { Hlargs = { italic = true, foreground = '#A5D6FF' } } },
          ['horizon'] = { { Hlargs = { italic = true, foreground = { from = 'Normal' } } } },
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
    config = function()
      require('neodim').setup({
        blend_color = hl.get('Normal', 'bg'),
        hide = { underline = false },
      })
    end,
  },

  {
    'rainbowhxch/beacon.nvim',
    config = function()
      local beacon = require('beacon')
      beacon.setup({
        minimal_jump = 20,
        ignore_buffers = { 'terminal', 'nofile' },
        ignore_filetypes = {
          'neo-tree',
          'qf',
          'NeogitCommitMessage',
          'NeogitPopup',
          'NeogitStatus',
          'packer',
          'trouble',
        },
      })
    end,
    enabled = false,
  },
}
