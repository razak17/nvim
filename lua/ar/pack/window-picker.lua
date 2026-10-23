ar.pack.add({
  {
    src = 'https://github.com/s1n7ax/nvim-window-picker',
    cond = function() return ar.get_plugin_cond('nvim-window-picker') end,
    lazy = false,
    keys = {
      {
        '<leader>wp',
        function()
          local picked_window_id = require('window-picker').pick_window({
            include_current_win = true,
          })
          vim.api.nvim_set_current_win(picked_window_id)
        end,
        desc = 'window-picker: pick window',
      },
      {
        '<leader>ws',
        function()
          local window = require('window-picker').pick_window({
            include_current_win = false,
          })
          local target_buffer = vim.fn.winbufnr(window)
          vim.api.nvim_win_set_buf(window, 0)
          if target_buffer ~= 0 then
            vim.api.nvim_win_set_buf(0, target_buffer)
          end
        end,
        desc = 'window-picker: swap window',
      },
    },
    setup = function()
      require('window-picker').setup({
        hint = 'floating-big-letter',
        show_prompt = false,
        selection_chars = 'HJKLUIOPNMYTGBVCREWQSZAFD',
        filter_rules = {
          autoselect_one = true,
          include_current_win = false,
          include_unfocusable_windows = false,
          buftype = { 'terminal', 'quickfix', 'nofile' },
          -- stylua: ignore
          bo = {
            filetype = {
              'neo-tree-popup', 'snacks_picker_input', 'snacks_picker_list',
              'NvimTree', 'neo-tree', 'notify', 'snacks_notif',
            },
            buftype = {
              'terminal', 'nofile', 'quickfix', 'help', 'prompt', 'notify', 'float',
            },
          },
        },
      })
    end,
  },
})
