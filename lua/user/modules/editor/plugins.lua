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
    'kylechui/nvim-surround',
    event = 'BufReadPre',
    config = function()
      require('nvim-surround').setup({
        move_cursor = false,
        keymaps = { visual = 'S' },
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
    'aarondiel/spread.nvim',
    init = function()
      rvim.nnoremap('gS', function() require('spread').out() end, 'spread: expand')
      rvim.nnoremap('gJ', function() require('spread').combine() end, 'spread: combine')
    end,
  },

  {
    'kazhala/close-buffers.nvim',
    init = function()
      rvim.nnoremap(
        '<leader>bc',
        function() require('close_buffers').wipe({ type = 'other' }) end,
        'close others'
      )
      rvim.nnoremap(
        '<leader>bx',
        function() require('close_buffers').wipe({ type = 'all', force = true }) end,
        'close others'
      )
    end,
  },

  {
    'karb94/neoscroll.nvim', -- NOTE: alternative: 'declancm/cinnamon.nvim'
    event = 'VeryLazy',
    config = function() require('neoscroll').setup({ hide_cursor = true }) end,
  },

  {
    'mizlan/iswap.nvim',
    event = { 'BufRead', 'BufNewFile' },
    init = function()
      rvim.nnoremap('<leader>ia', '<Cmd>ISwap<CR>', 'iswap: swap any')
      rvim.nnoremap('<leader>iw', '<Cmd>ISwapWith<CR>', 'iswap: swap with')
    end,
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
}
