local api, ui = vim.api, rvim.ui
local codicons = ui.codicons

return {
  'rcarriga/nvim-notify',
  keys = {
    { '<leader>nn', '<cmd>Notifications<CR>', desc = 'notify: show' },
    {
      '<leader>nx',
      function() require('notify').dismiss({ silent = true, pending = true }) end,
      desc = 'notify: dismiss notifications',
    },
  },
  init = function()
    local notify = require('notify')

    notify.setup({
      max_width = function() return math.floor(vim.o.columns * 0.6) end,
      max_height = function() return math.floor(vim.o.lines * 0.8) end,
      background_colour = 'NormalFloat',
      on_open = function(win)
        if api.nvim_win_is_valid(win) then
          api.nvim_win_set_config(win, { border = ui.current.border })
        end
      end,
      timeout = 5000,
      stages = 'fade_in_slide_out',
      top_down = false,
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

    local ignored = {
      'No information available',
      '[LSP] Format request failed, no matching language servers.',
    }

    vim.notify = function(msg, level, opts)
      if vim.tbl_contains(ignored, msg) then return end
      return notify(msg, level, opts)
    end

    require('telescope').load_extension('notify')
  end,
}
