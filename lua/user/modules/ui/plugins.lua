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
    vim.o.termguicolors = true
    notify.setup {
      stages = "fade_in_slide_out", -- fade
      timeout = 3000,
    }
    ---Send a notification
    --@param msg of the notification to show to the user
    --@param level Optional log level
    --@param opts Dictionary with optional options (timeout, etc)
    vim.notify = function(msg, level, opts)
      local l = vim.log.levels
      opts = opts or {}
      level = level or l.INFO
      local levels = {
        [l.DEBUG] = "Debug",
        [l.INFO] = "Information",
        [l.WARN] = "Warning",
        [l.ERROR] = "Error",
      }
      opts.title = opts.title or type(level) == "string" and level or levels[level]
      notify(msg, level, opts)
    end
  end,
  disable = not rvim.plugin.nvim_notify.active,
}

return ui
