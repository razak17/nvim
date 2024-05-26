return {
  {
    'folke/flash.nvim',
    opts = {
      modes = {
        char = {
          keys = { 'f', 'F', 't', 'T', ';' }, -- remove "," from keys
        },
        search = { enabled = false },
      },
      jump = { nohlsearch = true },
    },
    -- stylua: ignore
    keys = {
      { 's', function() require('flash').jump() end, mode = { 'n', 'x', 'o' } },
      { 'S', function() require('flash').treesitter() end, mode = { 'o', 'x' }, },
      { 'r', function() require('flash').remote() end, mode = 'o', desc = 'Remote Flash', },
      { '<c-s>', function() require('flash').toggle() end, mode = { 'c' }, desc = 'Toggle Flash Search', },
      { 'R', function() require('flash').treesitter_search() end, mode = { 'o', 'x' }, desc = 'Flash Treesitter Search', },
    },
  },
}
