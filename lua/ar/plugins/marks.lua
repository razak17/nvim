local minimal = ar.plugins.minimal

return {
  {
    desc = 'Neovim plugin for improved location list navigation',
    'cbochs/portal.nvim',
    cond = function() return ar.get_plugin_cond('portal.nvim', not minimal) end,
    -- stylua: ignore
    keys = {
      { 'g<c-i>', '<Cmd>Portal jumplist forward<CR>', desc = 'portal jump backward' },
      { 'g<c-o>', '<Cmd>Portal jumplist backward<CR>', desc = 'portal jump forward' },
    },
    opts = {},
  },
  {
    desc = 'Show jumplist in a floating window.',
    'razak17/whatthejump.nvim',
    cond = function()
      return ar.get_plugin_cond('whatthejump.nvim', not minimal)
    end,
    keys = { '<C-o>', '<C-i>' },
    opts = { winblend = 0 },
  },
}
