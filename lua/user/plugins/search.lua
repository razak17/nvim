local function leap_keys()
  require('leap').leap({
    target_windows = vim.tbl_filter(
      function(win) return rvim.falsy(vim.fn.win_gettype(win)) end,
      vim.api.nvim_tabpage_list_wins(0)
    ),
  })
end

return {
  {
    'ggandor/flit.nvim',
    keys = { 'f' },
    dependencies = { 'ggandor/leap.nvim' },
    opts = { labeled_modes = 'nvo', multiline = false },
  },
  {
    'ggandor/leap.nvim',
    keys = { { 's', leap_keys, mode = 'n' } },
    opts = { equivalence_classes = { ' \t\r\n', '([{', ')]}', '`"\'' } },
    config = function(_, opts)
      rvim.highlight.plugin('leap', {
        theme = {
          ['*'] = { { LeapBackdrop = { fg = '#707070' } } },
        },
      })
      require('leap').setup(opts)
    end,
  },
}
