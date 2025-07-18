local minimal = ar.plugins.minimal

return {
  -- BUG: Disable until this issue is fixed: https://github.com/folke/ts-comments.nvim/issues/72
  {
    'folke/ts-comments.nvim',
    cond = not minimal and false,
    event = 'VeryLazy',
    opts = {},
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    opts = { enable_autocmd = false },
    config = function(_, opts)
      vim.g.skip_ts_context_commentstring_module = true
      require('ts_context_commentstring').setup(opts)
    end,
  },
  {
    's1n7ax/nvim-comment-frame',
    cond = not minimal,
    keys = {
      {
        '<localleader>cf',
        '<Cmd>lua require("nvim-comment-frame").add_comment()<CR>',
        desc = 'comment-frame: add',
      },
      {
        '<localleader>cm',
        '<Cmd>lua require("nvim-comment-frame").add_multiline_comment()<CR>',
        desc = 'comment-frame: add multiline',
      },
    },
    opts = {
      disable_default_keymap = false,
      frame_width = 80,
      fill_char = '-',
      languages = {
        lua = {
          start_str = '--[[',
          end_str = ']]--',
          fill_char = '*',
          frame_width = 80,
          line_wrap_len = 60,
          auto_indent = false,
          add_comment_above = false,
        },
      },
    },
  },
}
