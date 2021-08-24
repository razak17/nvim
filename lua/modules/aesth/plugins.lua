local aesth = {}

local function load_conf(name)
  return require(string.format("modules.aesth.%s", name))
end

aesth["razak17/zephyr-nvim"] = { disable = not rvim.plugin.SANE.active }

aesth["glepnir/dashboard-nvim"] = {
  event = "BufWinEnter",
  config = load_conf "dashboard",
  disable = not rvim.plugin.dashboard.active and not rvim.plugin.SANE.active,
}

aesth["kyazdani42/nvim-web-devicons"] = { opt = true, disable = not rvim.plugin.SANE.active }

aesth["akinsho/nvim-bufferline.lua"] = {
  event = { "BufRead" },
  config = load_conf "bufferline",
  disable = not rvim.plugin.SANE.active,
}

aesth["kyazdani42/nvim-tree.lua"] = {
  event = "BufWinEnter",
  config = load_conf "nvimtree",
  disable = not rvim.plugin.tree.active,
}

aesth["razak17/galaxyline.nvim"] = {
  branch = "main",
  config = load_conf "statusline",
  disable = not rvim.plugin.statusline.active and not rvim.plugin.SANE.active,
}

aesth["lukas-reineke/indent-blankline.nvim"] = {
  event = { "BufRead" },
  config = load_conf "indent_blankline",
  disable = not rvim.plugin.indent_line.active,
}

aesth["lewis6991/gitsigns.nvim"] = {
  event = "BufWinEnter",
  config = load_conf "gitsigns",
  disable = not rvim.plugin.git_signs.active,
}

return aesth
