if
  ar.config.picker.variant ~= 'snacks'
  and ar.config.picker.variant ~= 'telescope'
then
  return {}
end

return {
  {
    'folke/snacks.nvim',
    optional = true,
    dependencies = { -- this will only be evaluated if snacks is enabled
      'razak17/software-licenses.nvim',
      keys = function()
        if ar.config.picker.variant == 'snacks' then
          return {
            {
              '<leader>fL',
              '<Cmd>SoftwareLicenses snacks<CR>',
              desc = 'software licenses',
            },
          }
        end
      end,
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    optional = true,
    dependencies = {
      {
        'razak17/software-licenses.nvim',
        keys = function()
          if ar.config.picker.variant == 'telescope' then
            local function licenses()
              require('telescope').extensions.software_licenses.find(
                ar.telescope.horizontal()
              )
            end
            return {
              { '<leader>fL', licenses, desc = 'software licenses' },
            }
          end
        end,
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            if ar.config.picker.variant == 'telescope' then
              vim.g.telescope_add_extension({ 'software_licenses' }, opts)
            end
          end,
        },
      },
    },
  },
}
