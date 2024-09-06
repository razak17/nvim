local minimal = ar.plugins.minimal

return {
  -- Games
  --------------------------------------------------------------------------------
  { 'ThePrimeagen/vim-be-good', cmd = 'VimBeGood', cond = not minimal },
  {
    'NStefan002/speedtyper.nvim',
    cmd = 'Speedtyper',
    cond = not minimal,
    opts = {},
  },
  {
    'Febri-i/snake.nvim',
    opts = {},
    cmd = { 'SnakeStart' },
    cond = not minimal,
    dependencies = { 'Febri-i/fscreen.nvim' },
  },
  {
    'NStefan002/2048.nvim',
    cmd = 'Play2048',
    cond = not minimal,
    opts = {},
  },
  {
    'NStefan002/15puzzle.nvim',
    cmd = 'Play15puzzle',
    cond = not minimal,
    opts = {},
  },
  {
    'willothy/strat-hero.nvim',
    cond = not minimal,
    cmd = 'StratHero',
    opts = {},
  },
}
