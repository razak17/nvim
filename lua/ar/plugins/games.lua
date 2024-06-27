return {
  -- Games
  --------------------------------------------------------------------------------
  { 'ThePrimeagen/vim-be-good', cmd = 'VimBeGood' },
  { 'NStefan002/speedtyper.nvim', cmd = 'Speedtyper', opts = {} },
  {
    'Febri-i/snake.nvim',
    opts = {},
    cmd = { 'SnakeStart' },
    dependencies = { 'Febri-i/fscreen.nvim' },
  },
  {
    'NStefan002/2048.nvim',
    cmd = 'Play2048',
    opts = {},
  },
  {
    'NStefan002/15puzzle.nvim',
    cmd = 'Play15puzzle',
    opts = {},
  },
  {
    'willothy/strat-hero.nvim',
    opts = {},
    cmd = 'StratHero',
  },
}
