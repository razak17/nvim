return {
  ------------------------------------------------------------------------------
  -- Themes {{{1
  ------------------------------------------------------------------------------
  {
    'LunarVim/horizon.nvim',
    cond = false,
    lazy = false,
    priority = 1000,
  },
  {
    'dotsilas/darcubox-nvim',
    cond = false,
    lazy = false,
    priority = 1000,
  },
  {
    'Wansmer/serenity.nvim',
    cond = false,
    priority = 1000,
    opts = {},
  },
  {
    'judaew/ronny.nvim',
    cond = false,
    priority = 1000,
    opts = {},
  },
  {
    'razak17/onedark.nvim',
    lazy = false,
    priority = 1000,
    opts = { variant = 'fill' },
    config = function(_, opts) require('onedark').setup(opts) end,
  },
  {
    'NTBBloodbath/doom-one.nvim',
    cond = false,
    lazy = false,
    config = function()
      vim.g.doom_one_pumblend_enable = true
      vim.g.doom_one_pumblend_transparency = 3
    end,
  },
  -- }}}
}
