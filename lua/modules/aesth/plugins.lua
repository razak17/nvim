local aesth = {}

local utils = require "utils"

aesth["glepnir/dashboard-nvim"] = {
  event = "BufWinEnter",
  config = utils.load_conf("aesth", "dashboard"),
  disable = not rvim.plugin.dashboard.active and not rvim.plugin.SANE.active,
}

aesth["akinsho/nvim-bufferline.lua"] = {
  event = { "BufRead" },
  config = utils.load_conf("aesth", "bufferline"),
  disable = not rvim.plugin.bufferline.active and not rvim.plugin.SANE.active,
}

aesth["NTBBloodbath/galaxyline.nvim"] = {
  branch = "main",
  event = "VimEnter",
  config = utils.load_conf("aesth", "statusline"),
  disable = not rvim.plugin.statusline.active and not rvim.plugin.SANE.active,
}

aesth["kyazdani42/nvim-web-devicons"] = {
  disable = not rvim.plugin.devicons.active and not rvim.plugin.SANE.active,
}

aesth["kyazdani42/nvim-tree.lua"] = {
  event = "BufWinEnter",
  config = utils.load_conf("aesth", "nvimtree"),
  commit = rvim.plugin.commits.nvimtree,
  disable = not rvim.plugin.tree.active,
}

aesth["lukas-reineke/indent-blankline.nvim"] = {
  event = { "BufRead" },
  config = utils.load_conf("aesth", "indent_blankline"),
  disable = not rvim.plugin.indent_line.active,
}

aesth["lewis6991/gitsigns.nvim"] = {
  event = "BufRead",
  config = utils.load_conf("aesth", "gitsigns"),
  disable = not rvim.plugin.git_signs.active,
}

return aesth
