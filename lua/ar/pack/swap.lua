ar.pack.add({
  {
    src = 'https://github.com/mizlan/iswap.nvim',
    cond = function()
      return ar.get_plugin_cond('iswap.nvim', not ar.plugins.minimal)
    end,
    keys = {
      { '<leader>ia', '<cmd>ISwap<CR>', desc = 'iswap: swap' },
      { '<leader>iw', '<cmd>ISwapWith<CR>', desc = 'iswap: swap with' },
    },
  },
  {
    src = 'https://github.com/Wansmer/sibling-swap.nvim',
    cond = function() return ar.get_plugin_cond('sibling-swap.nvim') end,
    -- stylua: ignore
    keys = {
      { '<leader>ih', function() require('sibling-swap').swap_with_left() end, desc = 'sibling-swap: swap left', },
      { '<leader>il', function() require('sibling-swap').swap_with_right() end, desc = 'sibling-swap: swap right', },
    },
    setup = function()
      require('sibling-swap').setup({
        use_default_keymaps = false,
        highlight_node_at_cursor = true,
      })
    end,
  },
})
