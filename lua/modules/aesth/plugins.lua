local conf = require('modules.aesth.config')
local aesth = {}

aesth['razak17/zephyr-nvim'] = {config = [[vim.cmd('colo zephyr')]]}

aesth['glepnir/dashboard-nvim'] = {
  event = {'BufRead', 'BufNewFile'},
  config = conf.dashboard,
  disable = not core.plugin.dashboard.active,
}

aesth['lukas-reineke/indent-blankline.nvim'] = {
  event = 'BufRead',
  branch = 'lua',
  config = conf.indent_blankline,
  disable = not core.plugin.indent_line.active,
}

aesth['akinsho/nvim-bufferline.lua'] = {
  event = "BufRead",
  config = conf.nvim_bufferline,
  requires = {{"kyazdani42/nvim-web-devicons", opt = true}},
}

aesth['kyazdani42/nvim-tree.lua'] = {
  event = {'BufRead', 'BufNewFile'},
  config = conf.nvim_tree,
  requires = {{"kyazdani42/nvim-web-devicons", opt = true}},
  disable = not core.plugin.tree.active,
}

aesth['glepnir/galaxyline.nvim'] = {
  branch = 'main',
  config = conf.galaxyline,
  requires = {{"kyazdani42/nvim-web-devicons", opt = true}},
}

aesth['lewis6991/gitsigns.nvim'] = {
  event = {'BufRead', 'BufNewFile'},
  config = conf.gitsigns,
  requires = {{'nvim-lua/plenary.nvim', opt = true}},
}

return aesth
