return {
  {
    'numToStr/Comment.nvim',
    cond = false,
    keys = { 'gcc', { 'gc', mode = { 'x', 'n', 'o' } } },
    opts = function(_, opts)
      local ok, integration =
        pcall(require, 'ts_context_commentstring.integrations.comment_nvim')
      if ok then opts.pre_hook = integration.create_pre_hook() end
    end,
  },
  {
    'folke/ts-comments.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  {
    's1n7ax/nvim-comment-frame',
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
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
}
