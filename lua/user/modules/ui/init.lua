local ui = {}

rvim.plugins.ui = {}

local utils = require("user.utils")
local plug_utils = require("user.utils.plugins")
local conf = utils.load_conf
local module = "ui"

local enabled = {
  "dashboard",
  "lualine",
  "bufferline",
  "devicons",
  "git_signs",
  "indent_line",
  "nvim_notify",
  "dressing",
  "headlines",
  "neodim",
  "neo_tree",
  "vim_highlighturl",
  "nightfox",
  "illuminate",
  "nui",
  "window_picker",
  "hlargs",
  "fidget",
  "beacon",
}
plug_utils.enable_plugins(module, enabled)

local disabled = {
  "nvimtree",
  "doom",
}
plug_utils.disable_plugins(module, disabled)

ui["glepnir/dashboard-nvim"] = {
  event = "BufWinEnter",
  config = conf(module, "dashboard"),
  disable = not rvim.plugins.ui.dashboard.active,
}

ui["akinsho/bufferline.nvim"] = {
  config = conf(module, "bufferline"),
  disable = not rvim.plugins.ui.bufferline.active,
}

ui["nvim-lualine/lualine.nvim"] = {
  config = conf(module, "lualine"),
  disable = not rvim.plugins.ui.lualine.active,
}

ui["kyazdani42/nvim-web-devicons"] = {
  config = conf(module, "nvim-web-devicons"),
  disable = not rvim.plugins.ui.devicons.active,
}

ui["kyazdani42/nvim-tree.lua"] = {
  config = conf(module, "nvimtree"),
  disable = not rvim.plugins.ui.nvimtree.active,
}

ui["lukas-reineke/indent-blankline.nvim"] = {
  config = conf(module, "indentline"),
  disable = not rvim.plugins.ui.indent_line.active,
}

ui["lewis6991/gitsigns.nvim"] = {
  event = "CursorHold",
  config = conf(module, "gitsigns"),
  disable = not rvim.plugins.ui.git_signs.active,
}

ui["rcarriga/nvim-notify"] = {
  cond = utils.not_headless, -- TODO: causes blocking output in headless mode
  config = conf(module, "notify"),
  disable = not rvim.plugins.ui.nvim_notify.active,
}

ui["stevearc/dressing.nvim"] = {
  event = "BufWinEnter",
  config = function() end,
  disable = not rvim.plugins.ui.dressing.active,
}

ui["lukas-reineke/headlines.nvim"] = {
  event = "BufWinEnter",
  setup = conf(module, "headlines").setup,
  config = conf(module, "headlines").config,
  disable = not rvim.plugins.ui.headlines.active,
}

ui["rainbowhxch/beacon.nvim"] = {
      config = function()
        local beacon = require('beacon')
        beacon.setup({
          minimal_jump = 20,
          ignore_buffers = { 'terminal', 'nofile', 'neorg://Quick Actions' },
          ignore_filetypes = {
            'neo-tree',
            'qf',
            'NeogitCommitMessage',
            'NeogitPopup',
            'NeogitStatus',
            'packer',
            'trouble',
          },
        })
        rvim.augroup('BeaconCmds', {
          {
            event = 'BufReadPre',
            pattern = '*.norg',
            command = function()
              beacon.beacon_off()
            end,
          },
        })
      end,
  disable = not rvim.plugins.ui.beacon.active,
}

ui["zbirenbaum/neodim"] = {
  config = function()
    require("neodim").setup({
      blend_color = require("user.utils.highlights").get("Normal", "bg"),
      alpha = 0.45,
      hide = {
        underline = false,
      },
    })
  end,
  disable = not rvim.plugins.ui.neodim.active,
}

ui["nvim-neo-tree/neo-tree.nvim"] = {
  branch = "v2.x",
  config = conf(module, "neo-tree"),
  disable = not rvim.plugins.ui.neo_tree.active,
}

ui["MunifTanjim/nui.nvim"] = { disable = not rvim.plugins.ui.nui.active }

ui["s1n7ax/nvim-window-picker"] = {
  tag = "1.*",
  config = conf(module, "window-picker"),
  disable = not rvim.plugins.ui.window_picker.active,
}

ui["itchyny/vim-highlighturl"] = {
  config = function()
    vim.g.highlighturl_guifg = require("user.utils.highlights").get("URL", "fg")
  end,
  disable = not rvim.plugins.ui.vim_highlighturl.active,
}

ui["EdenEast/nightfox.nvim"] = {
  disable = not rvim.plugins.ui.nightfox.active,
}

ui["NTBBloodbath/doom-one.nvim"] = {
  config = function()
    require("doom-one").setup({
      pumblend = {
        enable = true,
        transparency_amount = 3,
      },
    })
  end,
  disable = not rvim.plugins.ui.doom.active,
}

ui["RRethy/vim-illuminate"] = {
  config = function()
    vim.g.Illuminate_ftblacklist = { "alpha", "NvimTree", "dashboard", "neo-tree" }
    rvim.nnoremap("<a-n>", ':lua require"illuminate".next_reference{wrap=true}<cr>')
    rvim.nnoremap("<a-p>", ':lua require"illuminate".next_reference{reverse=true,wrap=true}<cr>')
  end,
  disable = not rvim.plugins.ui.illuminate.active,
}

ui["m-demare/hlargs.nvim"] = {
  config = function()
    require("user.utils.highlights").plugin("hlargs", {
      Hlargs = { italic = true, bold = false, foreground = "#A5D6FF" },
    })
    require("hlargs").setup({
      excluded_argnames = {
        declarations = { "use", "use_rocks", "_" },
        usages = {
          go = { "_" },
          lua = { "self", "use", "use_rocks", "_" },
        },
      },
    })
  end,
  disable = not rvim.plugins.ui.hlargs.active,
}

ui["j-hui/fidget.nvim"] = {
  config = function()
    require("fidget").setup()
  end,
  disable = not rvim.plugins.ui.fidget.active,
}

return ui
