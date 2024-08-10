local api = vim.api
local fmt = string.format
local ui, highlight = ar.ui, ar.highlight
local border = ui.current.border
local decor = ui.decorations

return {
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  {
    'Bekaboo/dropbar.nvim',
    event = { 'BufRead', 'BufNewFile' },
    cond = not ar.plugins.minimal,
    keys = {
      {
        '<leader>wo',
        function() require('dropbar.api').pick() end,
        desc = 'winbar: pick',
      },
    },
    opts = {
      general = {
        update_interval = 0,
        attach_events = {
          'OptionSet',
          'BufWinEnter',
          'BufWritePost',
          'BufEnter',
        },
        enable = function(buf, win)
          local b, w = vim.bo[buf], vim.wo[win]
          local decs = decor.get({ ft = b.ft, bt = b.bt, setting = 'winbar' })

          local show = false
          if not decs or ar.falsy(decs) then
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
        ui = { bar = { separator = fmt(' %s ', ui.icons.misc.chevron_right) } },
        kinds = {
          symbols = vim.tbl_map(
            function(value) return value .. ' ' end,
            require('lspkind').symbol_map
          ),
        },
      },
      menu = {
        win_configs = {
          border = border,
          col = function(menu)
            return menu.prev_menu and menu.prev_menu._win_configs.width + 1 or 0
          end,
        },
      },
    },
    config = function(_, opts)
      require('dropbar').setup(opts)

      highlight.plugin('dropbar', {
        theme = {
          ['onedark'] = {
            { DropBarIconUISeparator = { fg = { from = 'Label' } } },
            { DropBarIconUIIndicator = { link = 'Label' } },
            { DropBarMenuHoverEntry = { bg = 'NONE' } },
            { DropBarMenuCurrentContext = { link = 'CursorLine' } },
          },
        },
      })
    end,
  },
}
