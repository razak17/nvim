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
  {
    'RRethy/vim-illuminate',
    event = 'BufReadPre',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    init = function()
      map('n', 'gk', function() require('illuminate').goto_prev_reference() end, { desc = 'prev ref' })
      map('n', 'gj', function() require('illuminate').goto_next_reference() end, { desc = 'next ref' })
    end,
    config = function()
      rvim.highlight.plugin('leap', {
        theme = {
          ['*'] = {
            { IlluminatedWordText = { link = '@illuminate' } },
            { IlluminatedWordRead = { link = '@illuminate' } },
            { IlluminatedWordWrite = { link = '@illuminate' } },
          },
        },
      })
      require('illuminate').configure({
        modes_allowlist = { 'n' },
        filetypes_allowlist = { 'lua', 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
        filetypes_denylist = { 'buffer_manager' },
      })
    end,
  },
}
