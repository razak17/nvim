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
}

local utils = require "user.utils"

ui["glepnir/dashboard-nvim"] = {
  event = "BufWinEnter",
  config = utils.load_conf("ui", "dashboard"),
  disable = not rvim.plugins.ui.dashboard.active,
}

ui["akinsho/bufferline.nvim"] = {
  config = utils.load_conf("ui", "bufferline"),
  disable = not rvim.plugins.ui.bufferline.active,
}

ui["nvim-lualine/lualine.nvim"] = {
  config = utils.load_conf("ui", "lualine"),
  disable = not rvim.plugins.ui.lualine.active,
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
  event = "BufWinEnter",
  config = function()
    require("zephyr.util").plugin("dressing", { FloatTitle = { inherit = "Visual", bold = true } })
    require("dressing").setup {
      input = {
        winblend = 2,
        insert_only = false,
        border = rvim.style.border.line,
      },
      select = {
        telescope = require("telescope.themes").get_cursor {
          layout_config = {
            -- NOTE: the limit is half the max lines because this is the cursor theme so
            -- unless the cursor is at the top or bottom it realistically most often will
            -- only have half the screen available
            height = function(self, _, max_lines)
              local results = #self.finder.results
              local PADDING = 4 -- this represents the size of the telescope window
              local LIMIT = math.floor(max_lines / 2)
              return (results <= (LIMIT - PADDING) and results + PADDING or LIMIT)
            end,
          },
        },
      },
    }
  end,
  disable = not rvim.plugins.ui.dressing.active,
}

ui["lukas-reineke/headlines.nvim"] = {
  setup = function()
    -- https://observablehq.com/@d3/color-schemes?collection=@d3/d3-scale-chromatic
    -- NOTE: this must be set in the setup function or it will crash nvim...
    require("zephyr.util").plugin("Headlines", {
      Headline1 = { background = "#003c30", foreground = "White" },
      Headline2 = { background = "#00441b", foreground = "White" },
      Headline3 = { background = "#084081", foreground = "White" },
      Dash = { background = "#0b60a1", bold = true },
    })
  end,
  config = function()
    require("headlines").setup {
      markdown = {
        headline_highlights = { "Headline1", "Headline2", "Headline3" },
      },
    }
  end,
  disable = not rvim.plugins.ui.headlines.active,
}

ui["edluffy/specs.nvim"] = {
  config = function()
    -- NOTE: 'DanilaMihailov/beacon.nvim' is an alternative
    local specs = require "specs"
    specs.setup {
      popup = {
        delay_ms = 10,
        inc_ms = 10,
        blend = 10,
        width = 50,
        winhl = "PmenuSbar",
        resizer = specs.slide_resizer,
      },
    }
  end,
  disable = not rvim.plugins.ui.specs.active,
}

ui["narutoxy/dim.lua"] = {
  event = "BufWinEnter",
  requires = { "nvim-treesitter/nvim-treesitter", "neovim/nvim-lspconfig" },
  config = function()
    require("dim").setup {
      disable_lsp_decorations = true,
    }
  end,
  disable = not rvim.plugins.ui.dim.active,
}

ui["nvim-neo-tree/neo-tree.nvim"] = {
  branch = "v2.x",
  config = utils.load_conf("ui", "neo-tree"),
  requires = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "kyazdani42/nvim-web-devicons",
  },
  disable = not rvim.plugins.ui.neo_tree.active,
}

return ui
