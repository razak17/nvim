local minimal = rvim.plugins.minimal

return {
  ------------------------------------------------------------------------------
  -- Themes {{{1
  ------------------------------------------------------------------------------
  { 'Wansmer/serenity.nvim', priority = 1000, cond = not minimal, opts = {} },
  { 'judaew/ronny.nvim', priority = 1000, cond = not minimal, opts = {} },
  -- { 'oxfist/night-owl.nvim', lazy = false, priority = 1000 },
  { 'kvrohit/rasmus.nvim', lazy = false, cond = not minimal, priority = 1000 },
  {
    'razak17/onedark.nvim',
    lazy = false,
    priority = 1000,
    opts = { variant = 'fill' },
  },
  {
    'LunarVim/horizon.nvim',
    lazy = false,
    cond = not minimal,
    priority = 1000,
  },
  {
    'dotsilas/darcubox-nvim',
    lazy = false,
    cond = not minimal,
    priority = 1000,
  },
  {
    'NTBBloodbath/doom-one.nvim',
    cond = not minimal,
    lazy = false,
    config = function()
      vim.g.doom_one_pumblend_enable = true
      vim.g.doom_one_pumblend_transparency = 3
    end,
  },
  {
    'dgox16/oldworld.nvim',
    cond = not minimal,
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    'sontungexpt/witch',
    cond = not minimal and false,
    priority = 1000,
    lazy = false,
    opts = { style = 'dark' },
    config = function(_, opts) require('witch').setup(opts) end,
    -- Using lazy.nvim
    {
      'cdmill/neomodern.nvim',
      cond = not minimal and false,
      lazy = false,
      priority = 1000,
      config = function()
        require('neomodern').setup({
          highlights = {
            ['@namespace'] = { fg = '$constant' },
            ['@include'] = { fg = '$keyword' },
            ['@method'] = { fg = '$func' },
            ['@storageclass'] = { fg = '$constant' },
            ['@preProc'] = { fg = '$preproc' },
            ['@field'] = { fg = '$property' },
          },
        })
        require('neomodern').load()
      end,
    },
  },
  {
    'tribela/transparent.nvim',
    cond = rvim.ui.transparent.enable,
    event = 'VimEnter',
    opts = {},
  },
  -- }}}
}
