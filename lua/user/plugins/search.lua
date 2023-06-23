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
    enabled = false,
    keys = { 'f' },
    dependencies = { 'ggandor/leap.nvim' },
    opts = { labeled_modes = 'nvo', multiline = false },
  },
  {
    'ggandor/leap.nvim',
    enabled = false,
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
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      search = {
        mode = 'fuzzy',
      },
    },
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function() require('flash').jump() end,
      },
      {
        'S',
        mode = { 'o', 'x' },
        function() require('flash').treesitter() end,
      },
    },
  },
}
