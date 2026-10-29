local minimal = ar.plugins.minimal

ar.pack.add({
  {
    src = 'https://github.com/TobinPalmer/rayso.nvim',
    cmd = { 'Rayso' },
    cond = function() return ar.get_plugin_cond('rayso.nvim', not minimal) end,
    setup = function() require('rayso').setup() end,
  },
  {
    src = 'https://github.com/ellisonleao/carbon-now.nvim',
    cmd = 'CarbonNow',
    cond = function() return ar.get_plugin_cond('carbon-now.nvim', not minimal) end,
    setup = function() require('carbon-now').setup() end,
  },
  {
    src = 'https://github.com/Sanix-Darker/snips.nvim',
    cmd = { 'SnipsCreate' },
    cond = function() return ar.get_plugin_cond('snips.nvim', not minimal) end,
    setup = function() require('snips').setup() end,
  },
  {
    src = 'https://github.com/ethanholz/freeze.nvim',
    cmd = 'Freeze',
    cond = function() return ar.get_plugin_cond('freeze.nvim', not minimal) end,
    setup = function() require('freeze').setup() end,
  },
  {
    src = 'https://github.com/LionyxML/nvim-0x0',
    lazy = false,
    cond = function() return ar.get_plugin_cond('nvim-0x0', not minimal) end,
    init = function()
      ar.add_to_select('command_palette', {
        ['Upload Current File To 0x0.st'] = function()
          ar.pack.load('https://github.com/LionyxML/nvim-0x0')
          require('nvim-0x0').upload_current_file()
        end,
        ['Upload Selection To 0x0.st'] = function()
          ar.pack.load('https://github.com/LionyxML/nvim-0x0')
          require('nvim-0x0').upload_selection()
        end,
        ['Upload Yank To 0x0.st'] = function()
          ar.pack.load('https://github.com/LionyxML/nvim-0x0')
          require('nvim-0x0').upload_yank()
        end,
      })
    end,
    setup = function()
      require('nvim-0x0').setup({ use_default_keymaps = false })
    end,
  },
})
