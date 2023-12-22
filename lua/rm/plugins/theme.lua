return {
  ------------------------------------------------------------------------------
  -- Themes {{{1
  ------------------------------------------------------------------------------
  { 'LunarVim/horizon.nvim', cond = false, lazy = false, priority = 1000 },
  { 'dotsilas/darcubox-nvim', cond = false, lazy = false, priority = 1000 },
  { 'Wansmer/serenity.nvim', cond = false, priority = 1000, opts = {} },
  { 'judaew/ronny.nvim', cond = false, priority = 1000, opts = {} },
  { 'oxfist/night-owl.nvim', cond = false, lazy = false, priority = 1000 },
  { 'kvrohit/rasmus.nvim', cond = false, lazy = false, priority = 1000 },
  {
    'razak17/onedark.nvim',
    lazy = false,
    priority = 1000,
    opts = { variant = 'fill' },
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
