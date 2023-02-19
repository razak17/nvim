return {
  {
    'echasnovski/mini.ai',
    config = function()
      require('mini.ai').setup({ mappings = { around_last = '', inside_last = '' } })
    end,
  },

  {
    'echasnovski/mini.pairs',
    event = 'VeryLazy',
    config = function() require('mini.pairs').setup() end,
  },

  {
    'echasnovski/mini.bufremove',
    keys = {
      {
        '<leader>c',
        function() require('mini.bufremove').delete(0, false) end,
        desc = 'delete buffer',
      },
    },
  },

  {
    'echasnovski/mini.surround',
    event = 'VeryLazy',
    config = function()
      require('mini.surround').setup({
        mappings = {
          add = 'ys', -- Add surrounding in Normal and Visual modes
          delete = 'ds', -- Delete surrounding
          find = 'yf', -- Find surrounding (to the right)
          find_left = 'yF', -- Find surrounding (to the left)
          highlight = 'yh', -- Highlight surrounding
          replace = 'yr', -- Replace surrounding
          update_n_lines = 'yn', -- Update `n_lines`
        },
      })
    end,
  },

  {
    'echasnovski/mini.comment',
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    keys = { 'gcc', 'gc' },
    config = function()
      require('mini.comment').setup({
        hooks = {
          pre = function() require('ts_context_commentstring.internal').update_commentstring() end,
        },
      })
    end,
  },
}
