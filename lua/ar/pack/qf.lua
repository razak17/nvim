local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

ar.pack.add({
  {
    src = 'https://github.com/stevearc/quicker.nvim',
    cond = function() return ar.get_plugin_cond('quicker.nvim', not minimal) end,
    ft = 'qf',
    setup = function() require('quicker').setup({ borders = { vert = ' ' } }) end,
  },
  {
    src = 'https://github.com/yorickpeterse/nvim-pqf',
    cond = function() return ar.get_plugin_cond('nvim-pqf', not minimal) end,
    event = 'BufRead',
    setup = function() require('pqf').setup() end,
  },
  {
    src = 'https://github.com/kevinhwang91/nvim-bqf',
    cond = function() return ar.get_plugin_cond('nvim-bqf') end,
    ft = 'qf',
    setup = function()
      ar.highlight.plugin('bqf', {
        { BqfPreviewFloat = { link = 'NormalFloat' } },
        { BqfPreviewBorder = { link = 'FloatBorder' } },
      })

      require('bqf').setup({
        preview = {
          border = ar.ui.current.border.default,
          winblend = ar.config.ui.transparent.enable and 12 or 0,
        },
      })
    end,
  },
  {
    src = 'https://github.com/mei28/qfc.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('qfc.nvim', condition)
    end,
    ft = 'qf',
    setup = function()
      require('qfc').setup({ timeout = 4000, autoclose = true })
    end,
  },
  {
    src = 'https://github.com/brunobmello25/persist-quickfix.nvim',
    cond = function() return ar.get_plugin_cond('persist-quickfix.nvim') end,
    init = function()
      ar.add_to_select('command_palette', {
        ['Save Qf List'] = function()
          ar.pack.load('https://github.com/brunobmello25/persist-quickfix.nvim')
          vim.ui.input({
            prompt = 'List name: ',
            default = '',
          }, function(input)
            ar.pack.load(
              'https://github.com/brunobmello25/persist-quickfix.nvim'
            )
            if not input then return end
            require('persist-quickfix').save(input)
          end)
        end,
        ['Load Qf List'] = function()
          ar.pack.load('https://github.com/brunobmello25/persist-quickfix.nvim')
          vim.ui.input({
            prompt = 'List name: ',
            default = '',
          }, function(input)
            ar.pack.load(
              'https://github.com/brunobmello25/persist-quickfix.nvim'
            )
            if not input then return end
            require('persist-quickfix').load(input)
          end)
        end,
        ['Choose Qf List'] = function()
          ar.pack.load('https://github.com/brunobmello25/persist-quickfix.nvim')
          require('persist-quickfix').choose()
        end,
        ['Delete Qf List'] = function()
          ar.pack.load('https://github.com/brunobmello25/persist-quickfix.nvim')
          require('persist-quickfix').choose_delete()
        end,
      })
    end,
    ft = 'qf',
    setup = function() require('persist-quickfix').setup() end,
  },
})
