local function config()
  local api = vim.api
  local codicons = rvim.ui.codicons

  local notify = require('notify')

  notify.setup({
    max_width = function() return math.floor(vim.o.columns * 0.4) end,
    max_height = function() return math.floor(vim.o.lines * 0.8) end,
    background_colour = 'NormalFloat',
    on_open = function(win)
      if api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_config(win, { border = rvim.ui.current.border })
      end
    end,
    timeout = 500,
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

  vim.notify = function(msg, level, opts)
    if msg == 'No information available' then return end

    return notify(msg, level, opts)
  end
  require('telescope').load_extension('notify')
end

return {
  'rcarriga/nvim-notify',
  event = 'VeryLazy',
  keys = {
    { '<leader>nn', '<cmd>Notifications<CR>', desc = 'notify: show' },
    {
      '<leader>nx',
      function() require('notify').dismiss({ silent = true, pending = true }) end,
      desc = 'notify: dismiss notifications',
    },
  },
  config = config,
}
