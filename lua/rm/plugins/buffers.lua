local ui = rvim.ui
local fmt = string.format

return {
  {
    'chrisgrieser/nvim-early-retirement',
    enabled = false,
    -- enabled = not rvim.plugins.minimal,
    event = 'VeryLazy',
    opts = {
      minimumBufferNum = 4,
      notificationOnAutoClose = true,
    },
  },
  {

    'razak17/cybu.nvim',
    enabled = not rvim.plugins.minimal,
    event = { 'BufRead', 'BufNewFile' },
    opts = {
      position = { relative_to = 'win', anchor = 'topright' },
      style = { border = 'single', hide_buffer_id = true },
    },
  },
  {
    'razak17/buffer_manager.nvim',
    keys = {
      {
        '<M-Space>',
        '<Cmd>lua require("buffer_manager.ui").toggle_quick_menu()<CR>',
        desc = 'buffer manager: toggle',
      },
    },
    config = function()
      require('buffer_manager').setup({
        select_menu_item_commands = {
          v = { key = '<C-v>', command = 'vsplit' },
          h = { key = '<C-h>', command = 'split' },
        },
        borderchars = ui.border.common,
      })
      local bmui = require('buffer_manager.ui')
      local keys = '1234'
      for i = 1, #keys do
        local key = keys:sub(i, i)
        map(
          'n',
          fmt('<leader>%s', key),
          function() bmui.nav_file(i) end,
          { noremap = true, desc = 'buffer ' .. key }
        )
      end
    end,
  },
  {
    'stevearc/stickybuf.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'razak17/harpoon',
    keys = {
      {
        '<a-;>',
        '<Cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>',
        desc = 'harpoon: toggle menu',
      },
      {
        '<localleader>ha',
        '<Cmd>lua require("harpoon.mark").add_file()<CR>',
        desc = 'harpoon: add file',
      },
      {
        '<localleader>hn',
        '<Cmd>lua require("harpoon.ui").nav_next()<CR>',
        desc = 'harpoon: next file',
      },
      {
        '<localleader>hp',
        '<Cmd>lua require("harpoon.ui").nav_prev()<CR>',
        desc = 'harpoon: prev file',
      },
      {
        '<a-1>',
        '<Cmd>lua require("harpoon.ui").nav_file(1)<CR>',
        desc = 'harpoon: navigate to file 1',
      },
      {
        '<a-2>',
        '<Cmd>lua require("harpoon.ui").nav_file(2)<CR>',
        desc = 'harpoon: navigate to file 2',
      },
      {
        '<a-3>',
        '<Cmd>lua require("harpoon.ui").nav_file(3)<CR>',
        desc = 'harpoon: navigate to file 3',
      },
      {
        '<a-4>',
        '<Cmd>lua require("harpoon.ui").nav_file(4)<CR>',
        desc = 'harpoon: navigate to file 4',
      },
    },
    opts = {
      menu = {
        width = 60,
        borderchars = ui.border.common,
      },
    },
  },
}
