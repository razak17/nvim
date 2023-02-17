local function config()
  local utils = require('yanky.utils')
  local mapping = require('yanky.telescope.mapping')

  -- NOTE: use this workaround until https://github.com/gbprod/yanky.nvim/issues/37 is fixed
  vim.g.clipboard = {
    name = 'xsel_override',
    copy = {
      ['+'] = 'xsel --input --clipboard',
      ['*'] = 'xsel --input --primary',
    },
    paste = {
      ['+'] = 'xsel --output --clipboard',
      ['*'] = 'xsel --output --primary',
    },
    cache_enabled = 1,
  }

  require('yanky').setup({
    dbpath = join_paths(rvim.get_runtime_dir(), 'yanky', 'yanky.db'),
    ring = { storage = 'sqlite' },
    picker = {
      telescope = {
        mappings = {
          default = mapping.put('p'),
          i = {
            ['<c-p>'] = mapping.put('p'),
            ['<c-y>'] = mapping.put('P'),
            ['<c-x>'] = mapping.delete(),
            ['<c-r>'] = mapping.set_register(utils.get_default_register()),
          },
          n = {
            p = mapping.put('p'),
            P = mapping.put('P'),
            d = mapping.delete(),
            r = mapping.set_register(utils.get_default_register()),
          },
        },
      },
    },
  })
end

return {
  'razak17/yanky.nvim',
  event = 'BufReadPost',
  keys = {
    { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'yanky: put after' },
    { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'yanky: put before' },
    { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'yanky: gput after' },
    { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'yanky: gput before' },
    { '<m-n>', '<Plug>(YankyCycleForward)', desc = 'yanky: cycle forward' },
    { '<m-p>', '<Plug>(YankyCycleBackward)', desc = 'yanky: cycle backward' },
    {
      '<localleader>y',
      function()
        require('telescope').extensions.yank_history.yank_history(rvim.telescope.dropdown())
      end,
      desc = 'yanky: open yank history',
    },
  },
  config = config,
}
