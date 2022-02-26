return function()
  if #vim.api.nvim_list_uis() == 0 then
    -- no need to configure notifications in headless
    return
  end

  local renderer = require "notify.render"
  local Log = require "user.core.log"

  rvim.nvim_notify = {
    setup = {
      ---@usage Animation style one of { "fade", "slide", "fade_in_slide_out", "static" }
      stages = "fade_in_slide_out",

      ---@usage timeout for notifications in ms, default 5000
      timeout = 5000,

      -- Render function for notifications. See notify-render()
      render = function(bufnr, notif, highlights)
        if notif.title[1] == "" then
          return renderer.minimal(bufnr, notif, highlights)
        end
        return renderer.default(bufnr, notif, highlights)
      end,

      ---@usage minimum width for notification windows
      minimum_width = 50,

      ---@usage Icons for the different levels
      icons = {
        ERROR = "",
        WARN = "",
        INFO = "",
        HINT = "",
        TRACE = "✎",
      },
    },
  }

  ---@type table<string, fun(bufnr: number, notif: table, highlights: table)>
  -- vim.o.termguicolors = true
  local notify = require "notify"
  notify.setup(rvim.nvim_notify.setup)

  vim.notify = notify
  Log:configure_notifications(notify)
  require("telescope").load_extension "notify"
end
