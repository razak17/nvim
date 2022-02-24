local ui = {}

local utils = require "user.utils"

ui["glepnir/dashboard-nvim"] = {
  event = "BufWinEnter",
  config = utils.load_conf("ui", "dashboard"),
  disable = not rvim.plugin.dashboard.active and not rvim.plugin.SANE.active,
}

ui["akinsho/bufferline.nvim"] = {
  event = { "BufRead" },
  config = utils.load_conf("ui", "bufferline"),
  disable = not rvim.plugin.bufferline.active and not rvim.plugin.SANE.active,
}

ui["razak17/galaxyline.nvim"] = {
  branch = "main",
  event = "VimEnter",
  config = utils.load_conf("ui", "statusline"),
  disable = not rvim.plugin.statusline.active and not rvim.plugin.SANE.active,
}

ui["kyazdani42/nvim-web-devicons"] = {
  disable = not rvim.plugin.devicons.active and not rvim.plugin.SANE.active,
}

ui["kyazdani42/nvim-tree.lua"] = {
  event = "BufWinEnter",
  config = utils.load_conf("ui", "nvimtree"),
  commit = rvim.plugin.commits.nvimtree,
  disable = not rvim.plugin.nvimtree.active,
}

ui["lukas-reineke/indent-blankline.nvim"] = {
  event = { "BufRead" },
  config = utils.load_conf("ui", "indent_blankline"),
  disable = not rvim.plugin.indent_line.active,
}

ui["lewis6991/gitsigns.nvim"] = {
  config = utils.load_conf("ui", "gitsigns"),
  commit = rvim.plugin.commits.gitsigns,
  disable = not rvim.plugin.git_signs.active,
}

ui["rcarriga/nvim-notify"] = {
  cond = utils.not_headless, -- TODO: causes blocking output in headless mode
  config = function()
    local notify = require "notify"
    ---@type table<string, fun(bufnr: number, notif: table, highlights: table)>
    local renderer = require "notify.render"
    vim.o.termguicolors = true
    notify.setup {
      stages = "fade_in_slide_out",
      timeout = 3000,
      render = function(bufnr, notif, highlights)
        if notif.title[1] == "" then
          return renderer.minimal(bufnr, notif, highlights)
        end
        return renderer.default(bufnr, notif, highlights)
      end,
    }
    vim.notify = notify
    require("telescope").load_extension "notify"
  end,
  disable = not rvim.plugin.nvim_notify.active,
}

return ui
