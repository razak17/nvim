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
        winblend = ar_config.ui.transparent.enable and 0 or 12,
      },
    },
    config = function(_, opts)
      ar.highlight.plugin('bqf', {
        theme = {
          ['onedark'] = {
            { BqfPreviewFloat = { link = 'NormalFloat' } },
            { BqfPreviewBorder = { link = 'FloatBorder' } },
          },
        },
      })

      require('bqf').setup(opts)
    end,
  },
  {
    'mei28/qfc.nvim',
    cond = not minimal and niceties,
    ft = 'qf',
    opts = { timeout = 4000, autoclose = true },
  },
  {
    'brunobmello25/persist-quickfix.nvim',
    -- stylua: ignore
    keys = { '<leader>oq', '<Cmd>lua require("persist-quickfix").choose()<CR>', 'persist-quickfix: choose' },
    ft = 'qf',
    --- @type PersistQuickfix.Config
    opts = {},
  },
}
