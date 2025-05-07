local minimal = ar.plugins.minimal

return {
  {
    'numToStr/Comment.nvim',
    cond = false and not minimal and not ar.ts_extra_enabled,
    keys = { 'gcc', { 'gc', mode = { 'x', 'n', 'o' } } },
    opts = function(_, opts)
      local ok, integration =
        pcall(require, 'ts_context_commentstring.integrations.comment_nvim')
      if ok then opts.pre_hook = integration.create_pre_hook() end
    end,
  },
  {
    'folke/ts-comments.nvim',
    cond = not minimal and ar.ts_extra_enabled,
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
