local completion = {}

local conf = require "modules.completion.config"

local function load_conf(name)
  return require(string.format("modules.completion.%s", name))
end

completion["liuchengxu/vim-which-key"] = {
  event = { "BufWinEnter" },
  config = load_conf "which_key",
  disable = not rvim.plugin.SANE.active,
}

completion["mattn/emmet-vim"] = {
  event = "InsertEnter",
  config = conf.emmet,
  disable = not rvim.plugin.emmet.active,
}

completion["hrsh7th/nvim-compe"] = {
  event = "InsertEnter",
  config = load_conf "compe",
  disable = not rvim.plugin.SANE.active,
}

completion["rafamadriz/friendly-snippets"] = {
  event = "InsertEnter",
  disable = not rvim.plugin.friendly_snippets.active,
}

completion["hrsh7th/vim-vsnip"] = {
  event = "InsertEnter",
  config = load_conf "vsnip",
  disable = not rvim.plugin.vsnip.active,
}

completion["nvim-lua/plenary.nvim"] = { disable = not rvim.plugin.SANE.active }

completion["nvim-lua/popup.nvim"] = { disable = not rvim.plugin.SANE.active }

-- Telescope
completion["nvim-telescope/telescope.nvim"] = {
  config = load_conf "telescope",
  disable = not rvim.plugin.SANE.active,
}

completion["nvim-telescope/telescope-fzy-native.nvim"] = {
  opt = true,
  disable = not rvim.plugin.telescope_fzy.active,
}

completion["nvim-telescope/telescope-media-files.nvim"] = {
  opt = true,
  disable = not rvim.plugin.telescope_media_files.active,
}

completion["nvim-telescope/telescope-project.nvim"] = {
  opt = true,
  disable = not rvim.plugin.telescope_project.active,
}

return completion
