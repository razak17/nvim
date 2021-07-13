local conf = require('modules.aesth.config')
local aesth = {}

aesth['razak17/zephyr-nvim'] = {
  config = [[vim.cmd('colo zephyr')]],
  disable = not core.plugin.SANE.active,
}

aesth['glepnir/dashboard-nvim'] = {
  -- event = {'BufRead', 'BufNewFile'},
  event = "BufWinEnter",
  config = conf.dashboard,
  disable = not core.plugin.dashboard.active or not core.plugin.SANE.active,
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
  disable = not core.plugin.SANE.active,
}

aesth['kyazdani42/nvim-tree.lua'] = {
  event = {'BufRead', 'BufNewFile'},
  config = conf.nvim_tree,
  disable = not core.plugin.tree.active or not core.plugin.SANE.active,
}

aesth['glepnir/galaxyline.nvim'] = {
  branch = 'main',
  config = conf.galaxyline,
  disable = not core.plugin.statusline.active or not core.plugin.SANE.active,
}

aesth['lewis6991/gitsigns.nvim'] = {
  event = {'BufRead'},
  config = conf.gitsigns,
  disable = not core.plugin.git_signs.active,
}

return aesth
