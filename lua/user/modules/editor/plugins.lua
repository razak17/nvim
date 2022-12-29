return {
  { 'JoosepAlviste/nvim-ts-context-commentstring' },

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
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    config = function()
      local utils = require('Comment.utils')
      require('Comment').setup({
        pre_hook = function(ctx)
          local location = nil
          if ctx.ctype == utils.ctype.blockwise then
            location = require('ts_context_commentstring.utils').get_cursor_location()
          elseif ctx.cmotion == utils.cmotion.v or ctx.cmotion == utils.cmotion.V then
            location = require('ts_context_commentstring.utils').get_visual_start_location()
          end
          return require('ts_context_commentstring.internal').calculate_commentstring({
            key = ctx.ctype == utils.ctype.linewise and '__default' or '__multiline',
            location = location,
          })
        end,
      })
    end,
  },

  { 'psliwka/vim-dirtytalk', build = ':DirtytalkUpdate' },

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
    'nguyenvukhang/nvim-toggler',
    event = 'VeryLazy',
    init = function()
      rvim.nnoremap(
        '<leader>ii',
        '<cmd>lua require("nvim-toggler").toggle()<CR>',
        'nvim-toggler: toggle'
      )
    end,
    config = function()
      require('nvim-toggler').setup({
        inverses = {
          ['vim'] = 'emacs',
          ['let'] = 'const',
          ['margin'] = 'padding',
          ['-'] = '+',
          ['onClick'] = 'onSubmit',
          ['public'] = 'private',
        },
        remove_default_keybinds = true,
      })
    end,
  },

  {
    'mizlan/iswap.nvim',
    event = { 'BufRead', 'BufNewFile' },
    init = function()
      rvim.nnoremap('<leader>ia', '<Cmd>ISwap<CR>', 'iswap: swap any')
      rvim.nnoremap('<leader>iw', '<Cmd>ISwapWith<CR>', 'iswap: swap with')
    end,
  },
}
