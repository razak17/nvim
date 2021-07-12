local conf = require('modules.aesth.config')
local aesth = {}

aesth['razak17/zephyr-nvim'] = {config = [[vim.cmd('colo zephyr')]]}

aesth['glepnir/dashboard-nvim'] = {
  -- event = {'BufRead', 'BufNewFile'},
  event = "BufWinEnter",
  config = conf.dashboard,
  disable = not core.plugin.dashboard.active,
}

aesth['lukas-reineke/indent-blankline.nvim'] = {
  event = {'BufRead'},
  branch = 'lua',
  config = conf.indent_blankline,
  disable = not core.plugin.indent_line.active,
}

aesth['akinsho/nvim-bufferline.lua'] = {
  event = {'BufRead'},
  config = conf.nvim_bufferline,
  requires = {{"kyazdani42/nvim-web-devicons"}},
}

aesth['kyazdani42/nvim-tree.lua'] = {
  event = {'BufRead', 'BufNewFile'},
  config = conf.nvim_tree,
  disable = not core.plugin.tree.active,
}

aesth['glepnir/galaxyline.nvim'] = {
  branch = 'main',
  config = conf.galaxyline,
  disable = not core.plugin.statusline.active,
}

aesth['lewis6991/gitsigns.nvim'] = {event = {'BufRead'}, config = conf.gitsigns}

return aesth
