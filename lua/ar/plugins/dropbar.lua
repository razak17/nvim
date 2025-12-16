local api = vim.api
local fmt = string.format
local ui, highlight = ar.ui, ar.highlight
local border = ui.current.border.default
local decor = ui.decorations

return {
  {
    'Bekaboo/dropbar.nvim',
    event = { 'BufRead', 'BufNewFile' },
    cond = function()
      local condition = not ar.plugins.minimal
        and ar.config.ui.winbar.enable
        and ar.config.ui.winbar.variant == 'dropbar'
      return ar.get_plugin_cond('dropbar.nvim', condition)
    end,
    keys = {
      {
        '<leader>wo',
        function() require('dropbar.api').pick() end,
        desc = 'winbar: pick',
      },
    },
    opts = function()
      local symbol_map = require('lspkind').symbol_map

      return {
        bar = {
          update_interval = 0,
          attach_events = {
            'OptionSet',
            'BufWinEnter',
            'BufWritePost',
            'BufEnter',
            'FileType',
          },
          enable = function(buf, win)
            local b, w = vim.bo[buf], vim.wo[win]
            local decs = decor.get({ ft = b.ft, bt = b.bt, setting = 'winbar' })
            local bufname = api.nvim_buf_get_name(buf)
            local is_diffview = vim.startswith(bufname, 'diffview://')

            local show = false
            if not decs or ar.falsy(decs) or is_diffview then
              show = true
            else
              show = decs.ft == true or decs.bt == true
            end
            if not show then
              vim.opt_local.winbar = ''
              return false
            end
            return show
              and b.bt == ''
              and not w.diff
              and not api.nvim_win_get_config(win).zindex
              and api.nvim_buf_get_name(buf) ~= ''
          end,
        },
        icons = {
          ui = {
            bar = { separator = fmt(' %s ', ui.icons.misc.chevron_right) },
          },
          kinds = {
            symbols = vim.tbl_map(
              function(value) return value .. ' ' end,
              symbol_map
            ),
          },
        },
        menu = {
          win_configs = {
            border = border,
            col = function(menu)
              return menu.prev_menu and menu.prev_menu._win_configs.width + 1
                or 0
            end,
          },
        },
      }
    end,
    config = function(_, opts)
      require('dropbar').setup(opts)

      highlight.plugin('dropbar', {
        theme = {
          ['onedark'] = {
            { DropBarIconUISeparator = { fg = { from = 'Label' } } },
            { DropBarIconUIIndicator = { link = 'Label' } },
            { DropBarHover = { link = 'CursorLine' } },
            { DropBarMenuHoverEntry = { link = 'CursorLine' } },
            { DropBarMenuCurrentContext = { link = 'CursorLine' } },
          },
        },
      })
    end,
    dependencies = { 'nvim-telescope/telescope-fzf-native.nvim' },
  },
}
