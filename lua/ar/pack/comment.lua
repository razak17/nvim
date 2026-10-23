local enabled = not ar.plugins.minimal and ar.plugins.coding

ar.pack.add({
  -- BUG: Disable until this issue is fixed: https://github.com/folke/ts-comments.nvim/issues/72
  {
    src = 'https://github.com/folke/ts-comments.nvim',
    cond = function() return ar.get_plugin_cond('ts-comments.nvim', enabled) end,
    event = 'VeryLazy',

    setup = function()
      require('ts-comments').setup({
        lang = {
          typst = { '// %s', '/* %s */' },
        },
      })
    end,
  },
  {
    src = 'https://github.com/JoosepAlviste/nvim-ts-context-commentstring',
    lazy = false,
    cond = function()
      return ar.get_plugin_cond('nvim-ts-context-commentstring')
    end,

    setup = function()
      vim.g.skip_ts_context_commentstring_module = true
      require('ts_context_commentstring').setup({ enable_autocmd = false })
    end,
  },
  {
    src = 'https://github.com/s1n7ax/nvim-comment-frame',
    cond = function() return ar.get_plugin_cond('nvim-comment-frame', enabled) end,
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

    setup = function()
      require('nvim-comment-frame').setup({
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
      })
    end,
  },
})
