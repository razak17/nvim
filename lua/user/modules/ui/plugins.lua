return {
  'razak17/zephyr-nvim',
  'LunarVim/horizon.nvim',
  { 'fladson/vim-kitty', lazy = false },
  { 'nvim-tree/nvim-web-devicons', event = 'VeryLazy' },

  {
    'itchyny/vim-highlighturl',
    lazy = false,
    config = function()
      vim.g.highlighturl_guifg = require('user.utils.highlights').get('URL', 'fg')
    end,
  },

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
    'lukas-reineke/virt-column.nvim',
    event = 'BufReadPre',
    config = function()
      require('user.utils.highlights').plugin('virt_column', {
        { VirtColumn = { bg = 'None', fg = { from = 'VertSplit', alter = -50 } } },
      })
      require('virt-column').setup({ char = '│' })
    end,
  },

  {
    'uga-rosa/ccc.nvim',
    event = 'BufReadPre',
    cmd = { 'CccHighlighterToggle', 'CccHighlighterEnable', 'CccHighlighterDisable' },
    init = function() rvim.nnoremap('<leader>oc', '<cmd>CccHighlighterToggle<CR>', 'ccc: toggle') end,
    config = function()
      require('ccc').setup({
        win_opts = { border = rvim.style.border.current },
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
      require('user.utils.highlights').plugin('hlargs', {
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
