return {
  'JoosepAlviste/nvim-ts-context-commentstring',

  {
    'ghillb/cybu.nvim',
    event = { 'BufRead', 'BufNewFile' },
    config = function()
      require('cybu').setup({
        position = {
          relative_to = 'win',
          anchor = 'topright',
        },
        style = { border = 'single', hide_buffer_id = true },
      })
      rvim.nnoremap('H', '<Plug>(CybuPrev)', 'cybu: prev')
      rvim.nnoremap('L', '<Plug>(CybuNext)', 'cybu: next')
    end,
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
    opts = { hide_cursor = true },
  },

  {
    'psliwka/vim-dirtytalk',
    lazy = false,
    build = ':DirtytalkUpdate',
    config = function() vim.opt.spelllang:append('programming') end,
  },

  {

    'xiyaowong/accelerated-jk.nvim',
    event = 'VeryLazy',
    opts = {
      mappings = { j = 'gj', k = 'gk' },
    },
  },

  {
    'andrewferrier/debugprint.nvim',
    keys = {
      {
        '<leader>dp',
        function() return require('debugprint').debugprint({ variable = true }) end,
        expr = true,
        desc = 'debugprint: cursor',
      },
      {
        '<leader>do',
        function() return require('debugprint').debugprint({ motion = true }) end,
        mode = 'o',
        expr = true,
        desc = 'debugprint: operator',
      },
      { '<leader>dx', '<Cmd>DeleteDebugPrints<CR>', desc = 'debugprint: clear all' },
    },
    opts = { create_keymaps = false },
  },

  {
    'axelvc/template-string.nvim',
    ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    opts = { remove_template_string = true },
  },

  {
    'Wansmer/treesj',
    keys = {
      { 'gS', '<cmd>TSJSplit<CR>', desc = 'split to multiple lines' },
      { 'gJ', '<cmd>TSJJoin<CR>', desc = 'join to single line' },
    },
    opts = { use_default_keymaps = false, max_join_length = 150 },
  },

  {
    'mizlan/iswap.nvim',
    keys = {
      { '<leader>ia', '<cmd>ISwap<CR>', desc = 'iswap: swap any' },
      { '<leader>iw', '<cmd>ISwapWith<CR>', desc = 'iswap: swap with' },
    },
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
  },
}
