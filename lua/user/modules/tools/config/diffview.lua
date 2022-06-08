return function()
  require("diffview").setup({
    default_args = {
      DiffviewOpen = { "origin/HEAD" },
    },
    hooks = {
      diff_buf_read = function()
        vim.opt_local.wrap = false
        vim.opt_local.list = false
        vim.opt_local.colorcolumn = ""
      end,
    },
    enhanced_diff_hl = true,
    keymaps = {
      view = {
        q = "<Cmd>DiffviewClose<CR>",
      },
      file_panel = {
        q = "<Cmd>DiffviewClose<CR>",
      },
      file_history_panel = {
        q = "<Cmd>DiffviewClose<CR>",
      },
    },
  })
end
