local minimal = ar.plugins.minimal
local coding = ar.plugins.coding
local enabled = not minimal and coding

return {
  -- BUG: Disable until this issue is fixed: https://github.com/folke/ts-comments.nvim/issues/72
  {
    'folke/ts-comments.nvim',
    cond = function()
      return ar.get_plugin_cond('ts-comments.nvim', enabled)
    end,
    event = 'VeryLazy',
    opts = {
      lang = {
        typst = { '// %s', '/* %s */' },
      },
    },
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
    cond = enabled,
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
