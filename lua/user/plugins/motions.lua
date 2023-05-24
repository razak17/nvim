local bookmark = rvim.ui.codicons.misc.bookmark

return {
  { 'xiyaowong/accelerated-jk.nvim', event = 'VeryLazy', opts = { mappings = { j = 'gj', k = 'gk' } } },
  {
    'LeonHeidelbach/trailblazer.nvim',
    -- stylua: ignore
    keys = {
      '<M-l>', '<a-b>', '<a-j>', '<a-k>',
      { '<leader>ms', '<cmd>TrailBlazerSaveSession<CR>', desc = 'trailblazer: save session' },
      { '<leader>ml', '<cmd>TrailBlazerLoadSession<CR>', desc = 'trailblazer: load session' },
    },
    opts = {
      custom_session_storage_dir = join_paths(vim.fn.stdpath('data'), 'trailblazer'),
      trail_options = {
        newest_mark_symbol = bookmark,
        cursor_mark_symbol = bookmark,
        next_mark_symbol = bookmark,
        previous_mark_symbol = bookmark,
        number_line_color_enabled = false,
      },
    },
  },
}
