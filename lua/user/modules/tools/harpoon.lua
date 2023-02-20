return {
  'razak17/harpoon',
  event = 'BufReadPre',
  enabled = false,
  keys = {
    {
      '<leader>ma',
      function() require('harpoon.mark').add_file() end,
      desc = 'harpoon: add',
    },
    {
      '<leader>mn',
      function() require('harpoon.ui').nav_next() end,
      desc = 'harpoon: next',
    },
    {
      '<leader>mp',
      function() require('harpoon.ui').nav_prev() end,
      desc = 'harpoon: prev',
    },
    {
      '<leader>m;',
      function() require('harpoon.ui').toggle_quick_menu() end,
      desc = 'harpoon: ui',
    },
    {
      '<leader>mm',
      function() require('telescope').extensions.harpoon.marks() end,
      desc = 'harpoon: marks',
    },
  },
  config = function()
    require('harpoon').setup({
      menu = {
        borderchars = rvim.ui.border.common,
      },
    })
    rvim.highlight.plugin('harpoon', {
      theme = {
        ['zephyr'] = {
          { HarpoonTitle = { fg = { from = 'Winbar' } } },
          { HarpoonBorder = { fg = { from = 'FloatBorder' } } },
        },
      },
    })
    require('telescope').load_extension('harpoon')
  end,
}
