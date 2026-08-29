if
  ar.config.picker.variant ~= 'snacks'
  and ar.config.picker.variant ~= 'telescope'
then
  return {}
end

return {
  'razak17/software-licenses.nvim',
  {
    'folke/snacks.nvim',
    optional = true,
    keys = function()
      if ar.config.picker.variant == 'snacks' then
        return {
          {
            '<leader>fL',
            function() require('software_licenses').command('snacks') end,
            desc = 'software licenses',
          },
        }
      end
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    optional = true,
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
  },
}
