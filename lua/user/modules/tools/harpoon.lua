return {
  'razak17/harpoon',
  enabled = false,
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

    map(
      'n',
      '<leader>ma',
      function() require('harpoon.mark').add_file() end,
      { desc = 'harpoon: add' }
    )
    map(
      'n',
      '<leader>mn',
      function() require('harpoon.ui').nav_next() end,
      { desc = 'harpoon: next' }
    )
    map(
      'n',
      '<leader>mp',
      function() require('harpoon.ui').nav_prev() end,
      { desc = 'harpoon: prev' }
    )
    map(
      'n',
      '<leader>m;',
      function() require('harpoon.ui').toggle_quick_menu() end,
      { desc = 'harpoon: ui' }
    )
    map(
      'n',
      '<leader>mm',
      function() require('telescope').extensions.harpoon.marks() end,
      { desc = 'harpoon: marks' }
    )
    require('telescope').load_extension('harpoon')
  end,
}
