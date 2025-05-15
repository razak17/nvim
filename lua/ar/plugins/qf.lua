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
    init = function()
      ar.add_to_select_menu('command_palette', {
        ['Save Qf List'] = function()
          vim.ui.input({
            prompt = 'List name: ',
            default = '',
          }, function(input)
            if not input then return end
            require('persist-quickfix').save(input)
          end)
        end,
        ['Load Qf List'] = function()
          vim.ui.input({
            prompt = 'List name: ',
            default = '',
          }, function(input)
            if not input then return end
            require('persist-quickfix').load(input)
          end)
        end,
        ['Choose Qf List'] = function() require('persist-quickfix').choose() end,
        ['Delete Qf List'] = function()
          require('persist-quickfix').choose_delete()
        end,
      })
    end,
    ft = 'qf',
    --- @type PersistQuickfix.Config
    opts = {},
  },
}
