local border = ar.ui.current.border
local codicons = ar.ui.codicons
local diag_icons = codicons.lsp

return {
  desc = 'snacks notifier',
  recommended = true,
  'folke/snacks.nvim',
  -- stylua: ignore
  keys = {
    { '<leader>nx', function() Snacks.notifier.hide() end, desc = 'snacks: dismiss all notifications' },
    { '<leader>nh', function() Snacks.notifier.show_history() end, desc = 'snacks: show notification history' },
  },
  opts = function(_, opts)
    return vim.tbl_deep_extend('force', opts or {}, {
      styles = vim.tbl_deep_extend('force', opts.styles or {}, {
        notification = { border = border },
        notification_history = {
          border = border,
          wo = {
            winblend = ar_config.ui.transparent.enable and 0 or 5,
            wrap = true,
          },
        },
      }),
      notifier = {
        border = border,
        enabled = ar_config.notifier.enable
          and ar_config.notifier.variant == 'snacks',
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
          }

          for _, banned in ipairs(ignored_messages) do
            if string.find(n.msg, banned, 1, true) then return false end
          end

          return true
        end,
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
