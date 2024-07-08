local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'yorickpeterse/nvim-pqf',
    cond = not minimal,
    event = 'BufRead',
    opts = {},
  },
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    opts = {
      preview = {
        border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
        winblend = 0,
      },
    },
  },
  {
    'mei28/qfc.nvim',
    cond = not minimal and niceties,
    ft = 'qf',
    opts = { timeout = 4000, autoclose = true },
  },
}
