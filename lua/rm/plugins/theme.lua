return {
  ------------------------------------------------------------------------------
  -- Themes {{{1
  ------------------------------------------------------------------------------
  { 'LunarVim/horizon.nvim', lazy = false, priority = 1000 },
  { 'dotsilas/darcubox-nvim', lazy = false, priority = 1000 },
  { 'Wansmer/serenity.nvim', priority = 1000, opts = {} },
  { 'judaew/ronny.nvim', priority = 1000, opts = {} },
  {
    'razak17/onedark.nvim',
    lazy = false,
    priority = 1000,
    opts = { variant = 'fill' },
    config = function(_, opts) require('onedark').setup(opts) end,
  },
  {
    'NTBBloodbath/doom-one.nvim',
    lazy = false,
    config = function()
      vim.g.doom_one_pumblend_enable = true
      vim.g.doom_one_pumblend_transparency = 3
    end,
  },
  -- }}}
}