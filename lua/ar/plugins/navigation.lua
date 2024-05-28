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
      { 'S', function() require('flash').treesitter() end, mode = { 'n' }, },
      { 'r', function() require('flash').remote() end, mode = 'o', desc = 'remote flash', },
      { '<c-s>', function() require('flash').toggle() end, mode = { 'c' }, desc = 'toggle flash search', },
      { 'R', function() require('flash').treesitter_search() end, mode = { 'o', 'x' }, desc = 'Flash Treesitter Search', },
    },
  },
}
