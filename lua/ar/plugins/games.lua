local minimal = ar.plugins.minimal
local get_cond = ar.get_plugin_cond

return {
  -- Games
  --------------------------------------------------------------------------------
  {
    'ThePrimeagen/vim-be-good',
    cond = function() return get_cond('vim-be-good', not minimal) end,
    cmd = 'VimBeGood',
  },
  {
    'NStefan002/speedtyper.nvim',
    cond = function() return get_cond('speedtyper.nvim', not minimal) end,
    cmd = 'Speedtyper',
    opts = {},
  },
  {
    'Febri-i/snake.nvim',
    cond = function() return get_cond('snake.nvim', not minimal) end,
    opts = {},
    cmd = { 'SnakeStart' },
    dependencies = { 'Febri-i/fscreen.nvim' },
  },
  {
    'NStefan002/2048.nvim',
    cond = function() return get_cond('2048.nvim', not minimal) end,
    cmd = 'Play2048',
    opts = {},
  },
  {
    'NStefan002/15puzzle.nvim',
    cond = function() return get_cond('15puzzle.nvim', not minimal) end,
    cmd = 'Play15puzzle',
    opts = {},
  },
  {
    'willothy/strat-hero.nvim',
    cond = function() return get_cond('strat-hero.nvim', not minimal) end,
    cmd = 'StratHero',
    opts = {},
  },
}
