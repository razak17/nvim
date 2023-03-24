local fn, api, hl = vim.fn, vim.api, rvim.highlight

local function leap_keys()
  require('leap').leap({
    target_windows = vim.tbl_filter(
      function(win) return rvim.falsy(fn.win_gettype(win)) end,
      api.nvim_tabpage_list_wins(0)
    ),
  })
end

return {
  {
    'xiyaowong/accelerated-jk.nvim',
    event = 'VeryLazy',
    opts = { mappings = { j = 'gj', k = 'gk' } },
  },
  {
    'ggandor/leap.nvim',
    keys = { { 's', leap_keys, mode = 'n' } },
    opts = { equivalence_classes = { ' \t\r\n', '([{', ')]}', '`"\'' } },
    config = function(_, opts)
      hl.plugin('leap', {
        theme = {
          ['*'] = { { LeapBackdrop = { fg = '#707070' } } },
        },
      })
      require('leap').setup(opts)
    end,
  },
  {
    'ggandor/flit.nvim',
    keys = { 'n', 'f' },
    opts = { labeled_modes = 'nvo', multiline = false },
  },
  {
    'LeonHeidelbach/trailblazer.nvim',
    -- stylua: ignore
    keys = {
      '<M-l>', '<a-b>', '<a-j>', '<a-k>',
      { '<leader>ms', '<cmd>TrailBlazerSaveSession<CR>', desc = 'trailblazer: save session' },
      { '<leader>ml', '<cmd>TrailBlazerLoadSession<CR>', desc = 'trailblazer: load session' },
    },
    opts = {
      custom_session_storage_dir = join_paths(rvim.get_runtime_dir(), 'trailblazer'),
      trail_options = {
        current_trail_mark_list_type = 'quickfix',
      },
      mappings = {
        nv = { motions = { peek_move_next_down = '<a-j>', peek_move_previous_up = '<a-k>' } },
      },
    },
  },
}
