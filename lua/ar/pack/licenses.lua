local picker = ar.config.picker.variant
if picker ~= 'snacks' and picker ~= 'telescope' then return end

local backend = picker == 'snacks' and 'snacks.nvim' or 'telescope.nvim'
if not ar.get_plugin_cond(backend) then return end
if picker == 'telescope' and not require('ar.pack.telescope') then return end

ar.pack.add({
  src = 'https://github.com/razak17/software-licenses.nvim',
  dependencies = {
    {
      src = picker == 'snacks' and 'https://github.com/folke/snacks.nvim'
        or 'https://github.com/nvim-telescope/telescope.nvim',
    },
  },
  cmd = { 'SoftwareLicenses' },
  keys = {
    {
      '<leader>fL',
      function()
        if picker == 'snacks' then
          require('software_licenses').command('snacks')
        else
          require('telescope').load_extension('software_licenses')
          require('telescope').extensions.software_licenses.find(
            ar.telescope.horizontal()
          )
        end
      end,
      desc = 'software licenses',
    },
  },
})
