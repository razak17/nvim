local api, fn = vim.api, vim.fn
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
    keys = {
      { '<leader>c', '<Cmd>BDelete this<CR>', desc = 'buffer delete' },
      { '<leader>x', '<Cmd>BDelete this<CR><Cmd>q<CR>', desc = 'close & exit' },
    },
  },
  {
    'Pheon-Dev/buffalo-nvim',
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
        pick = {
          key = 'w',
          command = function()
            local idx = vim.fn.line('.')
            rvim.open_with_window_picker(idx + 1)
          end,
        },
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
    config = function()
      local action = require('arena').action

      require('arena').setup({
        max_items = nil,
        window = { border = 'single' },
        keybinds = {
          ['w'] = action(function(buf, info)
            rvim.open_with_window_picker(buf)
            fn.cursor(info.lnum, 0)
          end),
        },
      })
    end,
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
          local buf_ft = api.nvim_get_option_value('filetype', { buf = bufnr })
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
    branch = 'harpoon2',
    config = function()
      local harpoon = require('harpoon')
      harpoon:setup({ borderchars = ui.border.common })
      -- stylua: ignore
      map("n", "<a-;>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
      map('n', '<localleader>ha', function() harpoon:list():append() end)
      map('n', '<localleader>hn', function() harpoon:list():next() end)
      map('n', '<localleader>hp', function() harpoon:list():prev() end)
      map('n', '<a-1>', function() harpoon:list():select(1) end)
      map('n', '<a-2>', function() harpoon:list():select(2) end)
      map('n', '<a-3>', function() harpoon:list():select(3) end)
      map('n', '<a-4>', function() harpoon:list():select(4) end)
    end,
  },
}
