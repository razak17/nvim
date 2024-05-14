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
      style = {
        highlights = { background = 'NormalFloat' },
      },
    },
  },
  {
    'kazhala/close-buffers.nvim',
    cmd = { 'BDelete', 'BWipeout' },
    keys = {
      { '<leader>c', '<Cmd>BDelete this<CR>', desc = 'buffer delete' },
      -- { '<leader>x', '<Cmd>BDelete this<CR><Cmd>q<CR>', desc = 'close & exit' },
    },
  },
  {
    'sathishmanohar/quick-buffer-jump',
    cmd = { 'QuickBufferJump' },
    keys = {
      { '<M-u>', '<Cmd>QuickBufferJump<CR>', desc = 'quick buffer jump' },
    },
    config = function() require('quick_buffer_jump') end,
  },
  {
    'razak17/arena.nvim',
    event = 'VeryLazy',
    cmd = { 'ArenaToggle', 'ArenaOpen', 'ArenaClose' },
    keys = { { '<M-space>', '<Cmd>ArenaToggle<CR>', desc = 'arena: toggle' } },
    config = function()
      local action = require('arena').action

      require('arena').setup({
        max_items = 50,
        window = { Border = 'single' },
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
    'Pheon-Dev/buffalo-nvim',
    -- stylua: ignore
    keys = {
      { '<M-y>', '<Cmd>lua require("buffalo.ui").toggle_buf_menu()<CR>', desc = 'buffalo: toggle' },
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
      ui = {
        width = 100,
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
    'razak17/antelope',
    keys = {
      { '<M-a>', '<Cmd>Antelope buffers<CR>', 'antelope: buffers' },
      { '<M-m>', '<Cmd>Antelope marks<CR>', 'antelope: marks' },
    },
    opts = { notifications = false },
    config = function(_, opts)
      require('antelope').setup(opts)

      rvim.highlight.plugin('antelope', {
        { AntelopeBorder = { inherit = 'FloatBorder' } },
        { AntelopeNormal = { inherit = 'NormalFloat' } },
      })
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
    'razak17/buffer_manager.nvim',
    cond = false,
    -- stylua: ignore
    keys = {
      { '<M-Space>', '<Cmd>lua require("buffer_manager.ui").toggle_quick_menu()<CR>', desc = 'buffer manager: toggle' },
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
}
