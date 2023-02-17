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

    rvim.nnoremap('<leader>ma', function() require('harpoon.mark').add_file() end, 'harpoon: add')
    rvim.nnoremap('<leader>mn', function() require('harpoon.ui').nav_next() end, 'harpoon: next')
    rvim.nnoremap('<leader>mp', function() require('harpoon.ui').nav_prev() end, 'harpoon: prev')
    rvim.nnoremap(
      '<leader>m;',
      function() require('harpoon.ui').toggle_quick_menu() end,
      'harpoon: ui'
    )
    rvim.nnoremap(
      '<leader>mm',
      function()
        require('telescope').extensions.harpoon.marks(
          rvim.telescope.minimal_ui({ prompt_title = 'Harpoon Marks' })
        )
      end,
      'harpoon: marks'
    )
    require('telescope').load_extension('harpoon')
  end,
}
