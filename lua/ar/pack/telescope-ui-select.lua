if not require('ar.pack.telescope') then return end
if ar.config.picker.variant ~= 'telescope' then return end

ar.pack.add({
  src = 'https://github.com/nvim-telescope/telescope-ui-select.nvim',
  lazy = false,
  setup = function()
    vim.g.telescope_add_extension({ 'ui-select' }, nil, {
      ['ui-select'] = {
        require('telescope.themes').get_dropdown({}),
        name = 'ui-select',
      },
    })
  end,
})
