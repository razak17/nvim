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
      trail_options = { current_trail_mark_list_type = 'quickfix' },
      mappings = { nv = { motions = { peek_move_next_down = '<a-j>', peek_move_previous_up = '<a-k>' } } },
    },
  },
}
