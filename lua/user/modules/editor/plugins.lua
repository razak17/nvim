return {
  'JoosepAlviste/nvim-ts-context-commentstring',

  {
    'psliwka/vim-dirtytalk',
    build = ':DirtytalkUpdate',
    config = function() vim.opt.spelllang:append('programming') end,
  },

  {

    'xiyaowong/accelerated-jk.nvim',
    event = 'VeryLazy',
    config = function()
      require('accelerated-jk').setup({
        mappings = { j = 'gj', k = 'gk' },
        -- If the interval of key-repeat takes more than `acceleration_limit` ms, the step is reset
        -- acceleration_limit = 150,
      })
    end,
  },

  {
    'echasnovski/mini.surround',
    keys = { 'gz' },
    config = function()
      require('mini.surround').setup({
        mappings = {
          add = 'gza', -- Add surrounding in Normal and Visual modes
          delete = 'gzd', -- Delete surrounding
          find = 'gzf', -- Find surrounding (to the right)
          find_left = 'gzF', -- Find surrounding (to the left)
          highlight = 'gzh', -- Highlight surrounding
          replace = 'gzr', -- Replace surrounding
          update_n_lines = 'gzn', -- Update `n_lines`
        },
      })
    end,
  },

  {
    'axelvc/template-string.nvim',
    ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    config = function()
      require('template-string').setup({
        remove_template_string = true, -- remove backticks when there are no template string
      })
    end,
  },

  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter' },
    keys = {
      { 'gS', '<cmd>TSJSplit<CR>', desc = 'split to multiple lines' },
      { 'gJ', '<cmd>TSJJoin<CR>', desc = 'join to single line' },
    },
    opts = { use_default_keymaps = false, max_join_length = 150 },
  },

  -- buffer remove
  {
    'echasnovski/mini.bufremove',
    keys = {
      {
        '<leader>c',
        function() require('mini.bufremove').delete(0, false) end,
        desc = 'delete buffer',
      },
      {
        '<leader>bd',
        function() require('mini.bufremove').delete(0, true) end,
        desc = 'delete buffer (force)',
      },
    },
  },

  {
    'kazhala/close-buffers.nvim',
    keys = {
      {
        '<leader>bc',
        function() require('close_buffers').wipe({ type = 'other' }) end,
        desc = 'close others',
      },
      {
        '<leader>bx',
        function() require('close_buffers').wipe({ type = 'all', force = true }) end,
        desc = 'close all',
      },
    },
  },

  {
    'karb94/neoscroll.nvim', -- NOTE: alternative: 'declancm/cinnamon.nvim'
    event = 'VeryLazy',
    config = function() require('neoscroll').setup({ hide_cursor = true }) end,
  },

  {
    'mizlan/iswap.nvim',
    keys = {
      { '<leader>ia', '<cmd>ISwap<CR>', desc = 'iswap: swap any' },
      { '<leader>iw', '<cmd>ISwapWith<CR>', desc = 'iswap: swap with' },
    },
  },

  {
    'echasnovski/mini.comment',
    event = 'VeryLazy',
    config = function()
      require('mini.comment').setup({
        hooks = {
          pre = function() require('ts_context_commentstring.internal').update_commentstring() end,
        },
      })
    end,
  },

  {
    'ThePrimeagen/refactoring.nvim',
    keys = {
      {
        '<leader>r',
        function() require('refactoring').select_refactor() end,
        mode = 'v',
        noremap = true,
        silent = true,
        expr = false,
        desc = 'refactor',
      },
    },
    opts = {},
  },
}
