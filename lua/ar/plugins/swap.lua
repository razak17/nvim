local minimal = ar.plugins.minimal
local get_cond = ar.get_plugin_cond

return {
  ------------------------------------------------------------------------------
  -- Swap Text
  ------------------------------------------------------------------------------
  {
    'mizlan/iswap.nvim',
    cond = function() return get_cond('iswap.nvim', not minimal) end,
    keys = {
      { '<leader>ia', '<cmd>ISwap<CR>', desc = 'iswap: swap' },
      { '<leader>iw', '<cmd>ISwapWith<CR>', desc = 'iswap: swap with' },
    },
  },
  {
    'Wansmer/sibling-swap.nvim',
    cond = function() return ar.get_plugin_cond('sibling-swap.nvim') end,
    -- stylua: ignore
    keys = {
      { '<leader>ih', function() require('sibling-swap').swap_with_left() end, desc = 'sibling-swap: swap left', },
      { '<leader>il', function() require('sibling-swap').swap_with_right() end, desc = 'sibling-swap: swap right', },
    },
    opts = {
      use_default_keymaps = false,
      highlight_node_at_cursor = true,
    },
  },
}
