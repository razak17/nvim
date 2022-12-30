return {
  'razak17/zephyr-nvim',
  'LunarVim/horizon.nvim',
  { 'nvim-tree/nvim-web-devicons', event = 'VeryLazy' },

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

  ----------------------------------------------------------------------------------------------------
  -- Graveyard
  ----------------------------------------------------------------------------------------------------
  --
  -- {
  --   'rainbowhxch/beacon.nvim',
  --   config = function()
  --     local beacon = require('beacon')
  --     beacon.setup({
  --       minimal_jump = 20,
  --       ignore_buffers = { 'terminal', 'nofile', 'neorg://Quick Actions' },
  --       ignore_filetypes = {
  --         'neo-tree',
  --         'qf',
  --         'NeogitCommitMessage',
  --         'NeogitPopup',
  --         'NeogitStatus',
  --         'packer',
  --         'trouble',
  --       },
  --     })
  --     rvim.augroup('BeaconCmds', {
  --       {
  --         event = { 'BufReadPre' },
  --         pattern = { '*.norg' },
  --         command = function() beacon.beacon_off() end,
  --       },
  --     })
  --   end,
  --   disable = true,
  -- },
  --
  -- {
  --   'mvllow/modes.nvim',
  --   tag = 'v0.2.0',
  --   config = function() require('modes').setup() end,
  --   disable = true,
  -- },
  --
  -- { 'fladson/vim-kitty', disable = true },
  --
  -- { 'mtdl9/vim-log-highlighting', disable = true },
  --
  -- {
  --   'itchyny/vim-highlighturl',
  --   disable = true,
  --   config = function()
  --     vim.g.highlighturl_guifg = require('user.utils.highlights').get('URL', 'fg')
  --   end,
  -- },
  --
  -- {
  --   'levouh/tint.nvim',
  --   event = 'BufRead',
  --   disable = true,
  --   config = function()
  --     require('tint').setup({
  --       tint = -30,
  --       highlight_ignore_patterns = {
  --         'winseparator',
  --         'st.*',
  --         'comment',
  --         'panel.*',
  --         'telescope.*',
  --         'bqf.*',
  --       },
  --       window_ignore_function = function(win_id)
  --         if vim.wo[win_id].diff or vim.fn.win_gettype(win_id) ~= '' then return true end
  --         local buf = vim.api.nvim_win_get_buf(win_id)
  --         local b = vim.bo[buf]
  --         local ignore_bt = { 'terminal', 'prompt', 'nofile' }
  --         local ignore_ft = {
  --           'neo-tree',
  --           'packer',
  --           'diff',
  --           'toggleterm',
  --           'Neogit.*',
  --           'Telescope.*',
  --           'qf',
  --         }
  --         return rvim.any(b.bt, ignore_bt) or rvim.any(b.ft, ignore_ft)
  --       end,
  --     })
  --   end,
  -- },
}
