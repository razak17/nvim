return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
  config = function()
    rvim.highlight.plugin('diffview', {
      { DiffAddedChar = { bg = 'NONE', fg = { from = 'DiffAdd', attr = 'bg', alter = 30 } } },
      { DiffChangedChar = { bg = 'NONE', fg = { from = 'DiffChange', attr = 'bg', alter = 30 } } },
      { DiffviewStatusAdded = { link = 'DiffAddedChar' } },
      { DiffviewStatusModified = { link = 'DiffChangedChar' } },
      { DiffviewStatusRenamed = { link = 'DiffChangedChar' } },
      { DiffviewStatusUnmerged = { link = 'DiffChangedChar' } },
      { DiffviewStatusUntracked = { link = 'DiffAddedChar' } },
    })
    require('diffview').setup({
      default_args = {
        DiffviewFileHistory = { '%' },
      },
      hooks = {
        diff_buf_read = function()
          vim.opt_local.wrap = false
          vim.opt_local.list = false
          vim.opt_local.colorcolumn = ''
        end,
      },
      enhanced_diff_hl = true,
      keymaps = {
        view = { q = '<Cmd>DiffviewClose<CR>' },
        file_panel = { q = '<Cmd>DiffviewClose<CR>' },
        file_history_panel = { q = '<Cmd>DiffviewClose<CR>' },
      },
    })
    map('n', '<leader>gd', '<cmd>DiffviewOpen<CR>', { desc = 'diffview: open' })
    map('n', '<leader>gh', '<Cmd>DiffviewFileHistory<CR>', { desc = 'diffview: file history' })
    map('n', 'gh', [[:'<'>DiffviewFileHistory<CR>]], { desc = 'diffview: file history' })
  end,
}
