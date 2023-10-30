local ui = rvim.ui
local fmt = string.format

return {
  {
    'chrisgrieser/nvim-early-retirement',
    cond = not rvim.plugins.minimal and false,
    event = 'VeryLazy',
    opts = {
      minimumBufferNum = 4,
      notificationOnAutoClose = true,
    },
  },
  {

    'razak17/cybu.nvim',
    cond = not rvim.plugins.minimal,
    event = { 'BufRead', 'BufNewFile' },
    opts = {
      position = { relative_to = 'win', anchor = 'topright' },
      style = { border = 'single', hide_buffer_id = true },
    },
  },
  {
    'kazhala/close-buffers.nvim',
    cmd = { 'BDelete', 'BWipeout' },
    keys = { { '<leader>c', '<Cmd>BDelete this<CR>', desc = 'buffer delete' } },
  },
  {
    'razak17/buffalo-nvim',
    keys = {
      {
        '<M-Space>',
        '<Cmd>lua require("buffalo.ui").toggle_buf_menu()<CR>',
        desc = 'buffalo: toggle',
      },
    },
    opts = {
      borderchars = ui.border.common,
      buffer_commands = {
        edit = { key = '<CR>', command = 'edit' },
        split = { key = 's', command = 'split' },
        vsplit = { key = 'v', command = 'vsplit' },
      },
      go_to = { enabled = false },
      filter = {
        enabled = true,
        filter_tabs = '<M-t>',
        filter_buffers = '<M-z>',
      },
    },
    config = function(_, _opts)
      require('buffalo').setup(_opts)
      local opts = { noremap = true }
      local bui = require('buffalo.ui')
      map('n', '<s-l>', bui.nav_buf_next, opts)
      map('n', '<s-h>', bui.nav_buf_prev, opts)
      map({ 't', 'n' }, '<M-\\>', bui.toggle_tab_menu, opts)
    end,
  },
  {
    'dzfrias/arena.nvim',
    cmd = { 'ArenaToggle', 'ArenaOpen', 'ArenaClose' },
    keys = { { '<a-a>', '<Cmd>ArenaToggle<CR>', desc = 'arena: toggle' } },
    opts = {
      max_items = nil,
      window = { border = 'single' },
      keybinds = {
        ['w'] = function()
          local success, picker = pcall(require, 'window-picker')
          if not success then
            vim.notify('window-picker is not installed', vim.log.levels.ERROR)
            return
          end
          local picked_window_id = picker.pick_window()
          if picked_window_id then
            local line = vim.fn.getline('.')
            vim.api.nvim_set_current_win(picked_window_id)
            vim.cmd.edit(line)
          end
        end,
      },
    },
  },
  {
    'razak17/buffer_manager.nvim',
    cond = false,
    keys = {
      {
        '<M-Space>',
        '<Cmd>lua require("buffer_manager.ui").toggle_quick_menu()<CR>',
        desc = 'buffer manager: toggle',
      },
    },
    config = function()
      require('buffer_manager').setup({
        highlight = 'Normal',
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
    cmd = { 'PinBuffer', 'PinBuftype', 'PinFiletype', 'Unpin' },
    opts = {},
    config = function()
      require('stickybuf').setup({
        get_auto_pin = function(bufnr)
          local buf_ft = vim.api.nvim_buf_get_option(bufnr, 'ft')
          if buf_ft == 'DiffviewFiles' then
            -- this is a diffview tab, disable creating new windows
            -- (which would be the default behavior of handle_foreign_buffer)
            return {
              handle_foreign_buffer = function(buf) end,
            }
          end
          return require('stickybuf').should_auto_pin(bufnr)
        end,
      })
    end,
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
