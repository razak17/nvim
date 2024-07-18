local api = vim.api
local ui, highlight = ar.ui, ar.highlight
local border = ui.current.border

return {
  'Bekaboo/dropbar.nvim',
  event = { 'BufRead', 'BufNewFile' },
  cond = not ar.plugins.minimal,
  keys = {
    {
      '<leader>wp',
      function() require('dropbar.api').pick() end,
      desc = 'winbar: pick',
    },
  },
  opts = {
    general = {
      update_interval = 100,
      enable = function(buf, win)
        local b, w = vim.bo[buf], vim.wo[win]
        local decor =
          ui.decorations.get({ ft = b.ft, bt = b.bt, setting = 'winbar' })
        return decor
          and decor.ft ~= false
          and decor.bt ~= false
          and b.bt == ''
          and not w.diff
          and not api.nvim_win_get_config(win).zindex
          and api.nvim_buf_get_name(buf) ~= ''
      end,
    },
    icons = {
      ui = { bar = { separator = ' ' .. ui.icons.misc.chevron_right .. ' ' } },
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
}
