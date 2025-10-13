local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'yorickpeterse/nvim-pqf',
    cond = function() return ar.get_plugin_cond('nvim-pqf', not minimal) end,
    event = 'BufRead',
    opts = {},
  },
  {
    'kevinhwang91/nvim-bqf',
    cond = function() return ar.get_plugin_cond('nvim-bqf') end,
    ft = 'qf',
    opts = {
      preview = {
        border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
        winblend = ar_config.ui.transparent.enable and 12 or 0,
      },
    },
    config = function(_, opts)
      ar.highlight.plugin('bqf', {
        theme = {
          ['onedark'] = {
            { BqfPreviewFloat = { link = 'Normal' } },
            { BqfPreviewBorder = { link = 'VertSplit' } },
          },
        },
      })

      require('bqf').setup(opts)
    end,
  },
  {
    'mei28/qfc.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('qfc.nvim', condition)
    end,
    ft = 'qf',
    opts = { timeout = 4000, autoclose = true },
  },
  {
    'brunobmello25/persist-quickfix.nvim',
    cond = function() return ar.get_plugin_cond('persist-quickfix.nvim') end,
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
