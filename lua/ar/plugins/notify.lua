local api = vim.api
local ui = ar.ui
local codicons = ui.codicons

local function get_cond(plugin)
  local condition = not ar.plugins.minimal
    and ar_config.notifier.variant == 'nvim-notify'
  return ar.get_plugin_cond(plugin, condition)
end

return {
  {
    'rcarriga/nvim-notify',
    event = 'BufRead',
    cond = function() return get_cond('nvim-notify') end,
    -- stylua: ignore
    keys = {
      { '<leader>nh', '<cmd>Notifications<CR>', desc = 'notify: show' },
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
            api.nvim_win_set_config(win, { border = ui.current.border.default })
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
        -- TODO: fix where this is coming from and remove
        'vim.diagnostic.disable() is deprecated. Feature will be removed in Nvim 0.12',
      }

      ---@diagnostic disable-next-line: duplicate-set-field
      vim.notify = function(msg, level, opts)
        if vim.tbl_contains(ignored, msg) then return end
        return notify(msg, level, opts)
      end
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    optional = true,
    keys = function(_, keys)
      if get_cond('nvim-notify') then
        table.insert(keys or {}, {
          '<leader>fn',
          function() require('telescope').extensions.notify.notify() end,
          desc = 'notify: notifications',
        })
      end
    end,
    opts = function(_, opts)
      return get_cond('nvim-notify')
          and vim.g.telescope_add_extension({ 'notify' }, opts)
        or opts
    end,
  },
}
