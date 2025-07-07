local minimal = ar.plugins.minimal

return {
  {
    'folke/ts-comments.nvim',
    cond = not minimal and ar.ts_extra_enabled,
    event = 'VeryLazy',
    opts = {},
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
