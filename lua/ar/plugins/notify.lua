local api = vim.api
local ui = ar.ui
local codicons = ui.codicons

return {
  'rcarriga/nvim-notify',
  cond = not ar.plugins.minimal,
  event = 'BufRead',
  -- stylua: ignore
  keys = {
    { '<leader>nn', '<cmd>Notifications<CR>', desc = 'notify: show' },
    { '<leader>nx', function() require('notify').dismiss({ silent = true, pending = true }) end, desc = 'notify: dismiss notifications', },
  },
  init = function()
    local notify = require('notify')
    notify.setup({
      background_colour = ar.highlight.get('Normal', 'bg') or 'NONE',
      top_down = false,
      render = 'wrapped-compact',
      stages = 'fade_in_slide_out',
      on_open = function(win)
        if api.nvim_win_is_valid(win) then
          api.nvim_win_set_config(win, { border = ui.current.border })
        end
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

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.notify = function(msg, level, opts)
      if vim.tbl_contains(ignored, msg) then return end
      return notify(msg, level, opts)
    end
  end,
}
