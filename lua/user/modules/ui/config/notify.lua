return function()
  local api = vim.api
  -- this plugin is not safe to reload
  if vim.g.packer_compiled_loaded then
    return
  end

  if #vim.api.nvim_list_uis() == 0 then
    -- no need to configure notifications in headless
    return
  end

  local renderer = require('notify.render')
  local Log = require('user.core.log')

  rvim.nvim_notify = {
    setup = {
      max_width = function()
        return math.floor(vim.o.columns * 0.8)
      end,
      max_height = function()
        return math.floor(vim.o.lines * 0.8)
      end,
      background_colour = 'NormalFloat',
      on_open = function(win)
        if api.nvim_win_is_valid(win) then
          vim.api.nvim_win_set_config(win, { border = rvim.style.border.current })
        end
      end,
      ---@usage Animation style one of { "fade", "slide", "fade_in_slide_out", "static" }
      stages = 'fade_in_slide_out',

      ---@usage timeout for notifications in ms, default 5000
      timeout = 500,

      -- Render function for notifications. See notify-render()
      render = function(...)
        local notif = select(2, ...)
        local style = notif.title[1] == '' and 'minimal' or 'default'
        require('notify.render')[style](...)
      end,

      ---@usage minimum width for notification windows
      minimum_width = 50,

      ---@usage Icons for the different levels
      icons = {
        ERROR = '',
        WARN = '',
        INFO = '',
        HINT = '',
        TRACE = '✎',
      },
    },
  }

  ---@type table<string, fun(bufnr: number, notif: table, highlights: table)>
  local notify = require('notify')
  notify.setup(rvim.nvim_notify.setup)

  vim.notify = notify
  Log:configure_notifications(notify)

  require('telescope').load_extension('notify')

  require('which-key').register({
    ['<leader>nn'] = { ':Notifications<cr>', 'notify: show' },
    ['<leader>nx'] = { notify.dismiss, 'notify: dimiss' },
  })

  require('user.utils.highlights').plugin('notify', {
    NotifyERRORBorder = { bg = { from = 'NormalFloat' } },
    NotifyWARNBorder = { bg = { from = 'NormalFloat' } },
    NotifyINFOBorder = { bg = { from = 'NormalFloat' } },
    NotifyDEBUGBorder = { bg = { from = 'NormalFloat' } },
    NotifyTRACEBorder = { bg = { from = 'NormalFloat' } },
    NotifyERRORBody = { link = 'NormalFloat' },
    NotifyWARNBody = { link = 'NormalFloat' },
    NotifyINFOBody = { link = 'NormalFloat' },
    NotifyDEBUGBody = { link = 'NormalFloat' },
    NotifyTRACEBody = { link = 'NormalFloat' },
  })
end
