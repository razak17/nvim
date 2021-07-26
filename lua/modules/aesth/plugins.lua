local conf = require('modules.aesth.config')
local aesth = {}

aesth['razak17/zephyr-nvim'] = {disable = not rvim.plugin.SANE.active}

aesth['glepnir/dashboard-nvim'] = {
  event = "BufWinEnter",
  config = conf.dashboard,
  disable = not rvim.plugin.dashboard.active and not rvim.plugin.SANE.active,
}
aesth['kyazdani42/nvim-web-devicons'] = {opt = true, disable = not rvim.plugin.SANE.active}

aesth['akinsho/nvim-bufferline.lua'] = {
  event = {'BufRead'},
  config = conf.nvim_bufferline,
  disable = not rvim.plugin.SANE.active,
}

aesth['kyazdani42/nvim-tree.lua'] = {
  event = "BufWinEnter",
  config = conf.nvim_tree,
  disable = not rvim.plugin.tree.active,
}

aesth['razak17/galaxyline.nvim'] = {
  branch = 'main',
  config = conf.galaxyline,
  disable = not rvim.plugin.statusline.active and not rvim.plugin.SANE.active,
}

aesth['lukas-reineke/indent-blankline.nvim'] = {
  event = {'BufRead'},
  config = conf.indent_blankline,
  disable = not rvim.plugin.indent_line.active,
}


aesth['lewis6991/gitsigns.nvim'] = {
  event = "BufWinEnter",
  config = conf.gitsigns,
  disable = not rvim.plugin.git_signs.active,
}

return aesth
