return function()
  local api = vim.api
  local codicons = rvim.style.codicons

  local notify = require('notify')
  notify.setup({
    max_width = function() return math.floor(vim.o.columns * 0.8) end,
    max_height = function() return math.floor(vim.o.lines * 0.8) end,
    background_colour = 'NormalFloat',
    on_open = function(win)
      if api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_config(win, { border = rvim.style.border.current })
      end
    end,
    timeout = 500,
    stages = 'fade_in_slide_out',
    render = function(...)
      local notif = select(2, ...)
      local style = notif.title[1] == '' and 'minimal' or 'default'
      require('notify.render')[style](...)
    end,
    icons = {
      ERROR = codicons.lsp.error,
      WARN = codicons.lsp.warn,
      INFO = codicons.lsp.info,
      HINT = codicons.lsp.hint,
      TRACE = codicons.lsp.trace,
    },
  })

  vim.notify = notify
  require('telescope').load_extension('notify')
  require('which-key').register({
    ['<leader>nn'] = { ':Notifications<cr>', 'notify: show' },
    ['<leader>nx'] = { notify.dismiss, 'notify: dimiss' },
  })

  require('zephyr.utils').plugin('notify', {
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
