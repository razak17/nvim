local ui = {}

rvim.plugins.ui = {
  nvimtree = { active = true },
  dashboard = { active = true },
  statusline = { active = true },
  bufferline = { active = true },
  devicons = { active = true },
  git_signs = { active = true },
  indent_line = { active = true },
  nvim_notify = { active = true },
  dressing = { active = true },
}

local utils = require "user.utils"

ui["glepnir/dashboard-nvim"] = {
  event = "BufWinEnter",
  config = utils.load_conf("ui", "dashboard"),
  disable = not rvim.plugins.ui.dashboard.active,
}

ui["akinsho/bufferline.nvim"] = {
  event = { "BufRead" },
  config = utils.load_conf("ui", "bufferline"),
  disable = not rvim.plugins.ui.bufferline.active,
}

ui["razak17/galaxyline.nvim"] = {
  branch = "main",
  event = "VimEnter",
  config = utils.load_conf("ui", "statusline"),
  disable = not rvim.plugins.ui.statusline.active,
}

ui["kyazdani42/nvim-web-devicons"] = {
  disable = not rvim.plugins.ui.devicons.active,
}

ui["kyazdani42/nvim-tree.lua"] = {
  config = utils.load_conf("ui", "nvimtree"),
  disable = not rvim.plugins.ui.nvimtree.active,
}

ui["lukas-reineke/indent-blankline.nvim"] = {
  event = { "BufRead" },
  config = utils.load_conf("ui", "indentline"),
  disable = not rvim.plugins.ui.indent_line.active,
}

ui["lewis6991/gitsigns.nvim"] = {
  config = utils.load_conf("ui", "gitsigns"),
  disable = not rvim.plugins.ui.git_signs.active,
}

ui["rcarriga/nvim-notify"] = {
  cond = utils.not_headless, -- TODO: causes blocking output in headless mode
  config = utils.load_conf("ui", "notify"),
  disable = not rvim.plugins.ui.nvim_notify.active,
}

ui["stevearc/dressing.nvim"] = {
  config = function()
    require("dressing").setup {
      input = {
        winblend = 2,
        insert_only = false,
      },
      select = {
        winblend = 2,
        telescope = {
          theme = "dropdown",
        },
      },
    }
  end,
  disable = not rvim.plugins.ui.dressing.active,
}

return ui
