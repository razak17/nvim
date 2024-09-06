local minimal = ar.plugins.minimal
return {
  --------------------------------------------------------------------------------
  -- Share Code
  {
    'TobinPalmer/rayso.nvim',
    cmd = { 'Rayso' },
    cond = not minimal,
    opts = {},
  },
  {
    'ellisonleao/carbon-now.nvim',
    cmd = 'CarbonNow',
    cond = not minimal,
    opts = {},
  },
  {
    'Sanix-Darker/snips.nvim',
    cmd = { 'SnipsCreate' },
    cond = not minimal,
    opts = {},
  },
  {
    'ethanholz/freeze.nvim',
    cmd = 'Freeze',
    cond = not minimal,
    opts = {},
  },
}
