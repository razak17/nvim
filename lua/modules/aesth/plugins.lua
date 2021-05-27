local conf = require('modules.aesth.config')
local aesth = {}

aesth['razak17/zephyr-nvim'] = {config = [[vim.cmd('colo zephyr')]]}

aesth['glepnir/dashboard-nvim'] = {event = "VimEnter", config = conf.dashboard}

aesth['lukas-reineke/indent-blankline.nvim'] =
    {event = 'VimEnter', branch = 'lua', config = conf.indent_blankline}

aesth['akinsho/nvim-bufferline.lua'] = {
  event = "VimEnter",
  config = conf.nvim_bufferline,
  requires = {{"kyazdani42/nvim-web-devicons", opt = true}}
}

aesth['sunjon/shade.nvim'] = {
  event = "BufReadPre",
  config = function()
    require'shade'.setup({keys = {toggle = '<Leader>aS'}})
  end
}

aesth['kyazdani42/nvim-tree.lua'] = {
  event = {'BufRead', 'BufNewFile'},
  config = conf.nvim_tree,
  requires = {{"kyazdani42/nvim-web-devicons", opt = true}}
}

aesth['glepnir/galaxyline.nvim'] = {
  branch = 'main',
  config = conf.galaxyline,
  requires = {{"kyazdani42/nvim-web-devicons", opt = true}}
}

aesth['lewis6991/gitsigns.nvim'] = {
  event = {'BufRead', 'BufNewFile'},
  config = conf.gitsigns,
  requires = {{'nvim-lua/plenary.nvim', opt = true}}
}

return aesth
