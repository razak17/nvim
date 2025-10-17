return {
  ------------------------------------------------------------------------------
  -- Sort
  ------------------------------------------------------------------------------
  {
    'sQVe/sort.nvim',
    cmd = { 'Sort' },
    -- stylua: ignore
    init = function()
      vim.g.whichkey_add_spec({'<localleader>S', group = 'Sort', mode = { 'n', 'x' }, })
    end,
    -- stylua: ignore
    keys = {
      { '<localleader>Ss', ':Sort<CR>', desc = 'sort: selection', mode = { 'n', 'x' }, silent = true },
      { '<localleader>SS', ':Sort!<CR>', desc = 'sort: selection (reverse)', mode = { 'n', 'x' }, silent = true },
      { '<localleader>Si', ':Sort i<CR>', desc = 'sort: ignore case', mode = { 'n', 'x' }, silent = true },
      { '<localleader>SI', ':Sort! i<CR>', desc = 'sort: ignore case (reverse)', mode = { 'n', 'x' }, silent = true },
    },
  },
  {
    'mtrajano/tssorter.nvim',
    -- stylua: ignore
    keys = {
      { '<leader>is', function() require('tssorter').sort() end, desc = 'tssorter: sort' },
      { '<leader>iS', function() require('tssorter').sort({ reverse = true }) end, desc = 'tssorter: reverse sort' },
    },
    opts = {},
  },
}
