return {
  {
    'nvim-telescope/telescope.nvim',
    optional = true,
    dependencies = {
      {
        'nvim-telescope/telescope-ui-select.nvim',
        cond = function() return ar_config.picker.variant == 'telescope' end,
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'ui-select' }, opts, {
              ['ui-select'] = {
                require('telescope.themes').get_dropdown({}),
                name = 'ui-select',
              },
            })
          end,
        },
      },
    },
  },
}
