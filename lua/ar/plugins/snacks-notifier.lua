local border = ar.ui.current.border.default
local codicons = ar.ui.codicons
local diag_icons = codicons.lsp

return {
  desc = 'snacks notifier',
  recommended = true,
  'folke/snacks.nvim',
  -- stylua: ignore
  keys = function(_, keys)
    keys = keys or {}
    if ar.config.notifier.variant == 'snacks' then
      ar.list_insert(keys, {
        { '<leader>nx', function() Snacks.notifier.hide() end, desc = 'snacks: dismiss all notifications' },
        { '<leader>nh', function() Snacks.notifier.show_history() end, desc = 'snacks: show notification history' },
      })
    end
  end,
  opts = function(_, opts)
    return vim.tbl_deep_extend('force', opts or {}, {
      styles = vim.tbl_deep_extend('force', opts.styles or {}, {
        notification = { border = border },
        notification_history = {
          border = vim.o.winborder,
          wo = {
            winblend = ar.config.ui.transparent.enable and 0 or 5,
            wrap = true,
          },
        },
      }),
      notifier = {
        border = border,
        enabled = ar.config.notifier.variant == 'snacks',
        filter = function(n)
          local ignored_messages = {
            'Neo-tree',
            'No information available',
            'Toggling hidden files',
            'Failed to attach to',
            'No items, skipping',
            'Config Change Detected',
            'Executing query',
            'Done after',
            'Failed to watch'
          }

          for _, banned in ipairs(ignored_messages) do
            if string.find(n.msg, banned, 1, true) then return false end
          end

          return true
        end,
        margin = { top = 0, right = 1, bottom = 1 },
        icons = {
          error = diag_icons.error,
          warn = diag_icons.warn,
          info = diag_icons.info,
          debug = codicons.misc.bug_alt,
          trace = diag_icons.trace,
        },
        style = 'fancy',
        top_down = false,
      },
    })
  end,
}
