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
  -- }}}
}
