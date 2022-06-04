local ui = {}

rvim.plugins.ui = {
  nvimtree = { active = false },
  dashboard = { active = true },
  lualine = { active = true },
  bufferline = { active = true },
  devicons = { active = true },
  git_signs = { active = true },
  indent_line = { active = true },
  nvim_notify = { active = true },
  dressing = { active = true },
  headlines = { active = true },
  specs = { active = false },
  dim = { active = true },
  neo_tree = { active = true },
  vim_highlighturl = { active = true },
  nightfox = { active = true },
  illuminate = { active = true },
}

local utils = require("user.utils")
local conf = utils.load_conf

ui["glepnir/dashboard-nvim"] = {
  event = "BufWinEnter",
  config = conf("ui", "dashboard"),
  disable = not rvim.plugins.ui.dashboard.active,
}

ui["akinsho/bufferline.nvim"] = {
  config = conf("ui", "bufferline"),
  disable = not rvim.plugins.ui.bufferline.active,
}

ui["nvim-lualine/lualine.nvim"] = {
  config = conf("ui", "lualine"),
  disable = not rvim.plugins.ui.lualine.active,
}

ui["kyazdani42/nvim-web-devicons"] = {
  config = conf("ui", "nvim-web-devicons"),
  disable = not rvim.plugins.ui.devicons.active,
}

ui["kyazdani42/nvim-tree.lua"] = {
  config = conf("ui", "nvimtree"),
  disable = not rvim.plugins.ui.nvimtree.active,
}

ui["lukas-reineke/indent-blankline.nvim"] = {
  event = { "BufRead" },
  config = conf("ui", "indentline"),
  disable = not rvim.plugins.ui.indent_line.active,
}

ui["lewis6991/gitsigns.nvim"] = {
  event = "CursorHold",
  config = conf("ui", "gitsigns"),
  disable = not rvim.plugins.ui.git_signs.active,
}

ui["rcarriga/nvim-notify"] = {
  cond = utils.not_headless, -- TODO: causes blocking output in headless mode
  config = conf("ui", "notify"),
  disable = not rvim.plugins.ui.nvim_notify.active,
}

ui["stevearc/dressing.nvim"] = {
  event = "BufWinEnter",
  config = function() end,
  disable = not rvim.plugins.ui.dressing.active,
}

ui["lukas-reineke/headlines.nvim"] = {
  event = "BufWinEnter",
  setup = conf("ui", "headlines").setup,
  config = conf("ui", "headlines").config,
  disable = not rvim.plugins.ui.headlines.active,
}

ui["edluffy/specs.nvim"] = {
  event = "BufWinEnter",
  config = function()
    require("zephyr.util").plugin("beacon", {
      Beacon = { link = "Cursor" },
    })
    -- NOTE: 'DanilaMihailov/beacon.nvim' is an alternative
    local specs = require("specs")
    specs.setup({
      popup = {
        delay_ms = 10,
        inc_ms = 10,
        blend = 10,
        width = 50,
        winhl = "PmenuSbar",
        resizer = specs.slide_resizer,
      },
    })
  end,
  disable = not rvim.plugins.ui.specs.active,
}

ui["narutoxy/dim.lua"] = {
  event = "BufWinEnter",
  requires = { "nvim-treesitter/nvim-treesitter", "neovim/nvim-lspconfig" },
  config = function()
    require("dim").setup({
      disable_lsp_decorations = true,
    })
  end,
  disable = not rvim.plugins.ui.dim.active,
}

ui["nvim-neo-tree/neo-tree.nvim"] = {
  branch = "v2.x",
  config = conf("ui", "neo-tree"),
  requires = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "kyazdani42/nvim-web-devicons",
    {
      "s1n7ax/nvim-window-picker",
      tag = "1.*",
      config = conf("ui", "window-picker"),
    },
  },
  disable = not rvim.plugins.ui.neo_tree.active,
}

ui["itchyny/vim-highlighturl"] = {
  config = function()
    vim.g.highlighturl_guifg = require("zephyr.util").get_hl("URL", "fg")
  end,
  disable = not rvim.plugins.ui.vim_highlighturl.active,
}

ui["EdenEast/nightfox.nvim"] = {
  disable = not rvim.plugins.ui.nightfox.active,
}

ui["RRethy/vim-illuminate"] = {
  config = function()
    vim.g.Illuminate_ftblacklist = { "alpha", "NvimTree", "dashboard", "neo-tree" }
  end,
  disable = not rvim.plugins.ui.illuminate.active,
}

return ui
