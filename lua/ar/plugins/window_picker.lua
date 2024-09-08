local api = vim.api

return {
  {
    's1n7ax/nvim-window-picker',
    version = '2.*',
    keys = {
      {
        '<leader>wp',
        function()
          local picked_window_id = require('window-picker').pick_window({
            include_current_win = true,
          }) or api.nvim_get_current_win()
          api.nvim_set_current_win(picked_window_id)
        end,
        desc = 'pick window',
      },
      {
        '<leader>ws',
        function()
          local window = require('window-picker').pick_window({
            include_current_win = false,
          })
          local target_buffer = vim.fn.winbufnr(window)
          api.nvim_win_set_buf(window, 0)
          if target_buffer ~= 0 then api.nvim_win_set_buf(0, target_buffer) end
        end,
        desc = 'swap window',
      },
    },
    opts = {
      hint = 'floating-big-letter',
      selection_chars = 'HJKLUIOPNMYTGBVCREWQSZAFD',
      filter_rules = {
        autoselect_one = true,
        bo = {
          filetype = { 'neo-tree-popup', 'quickfix' },
          buftype = { 'terminal', 'quickfix', 'nofile' },
        },
      },
    },
  },
  {
    'CodingdAwn/vim-choosewin',
    cond = false,
    keys = { { '<leader>ow', '<Plug>(choosewin)', desc = 'choose window' } },
    config = function() vim.g.choosewin_overlay_enable = 1 end,
  },
  {
    'tkmpypy/chowcho.nvim',
    cond = false,
    keys = {
      { '<leader>wP', '<Cmd>Chowcho<CR>', desc = 'chowcho: toggle' },
    },
    opts = {
      -- stylua: ignore
      labels={'h','j','k','l','u','i','o','p','n','m','y','t','g','b','v','c','r','e','w','q','s','x','z','a','f','d'},
      ignore_case = true,
    },
  },
}
