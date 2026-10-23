ar.pack.add({
  {
    src = 'https://github.com/nvim-mini/mini.extra',
    cond = function() return ar.get_plugin_cond('mini.extra') end,
    setup = function() require('mini.extra').setup() end,
  },
  {
    src = 'https://github.com/nvim-mini/mini.hipatterns',
    cond = function() return ar.get_plugin_cond('mini.hipatterns') end,
  },
  {
    src = 'https://github.com/nvim-mini/mini.bracketed',
    cond = function()
      return ar.get_plugin_cond('mini.bracketed', not ar.plugins.minimal)
    end,
    event = { 'BufRead', 'BufNewFile' },
    setup = function()
      require('mini.bracketed').setup({ buffer = { suffix = '' } })
    end,
  },
  {
    src = 'https://github.com/nvim-mini/mini.trailspace',
    cond = function()
      return ar.get_plugin_cond('mini.trailspace', not ar.plugins.minimal)
    end,
    init = function()
      ar.add_to_select('command_palette', {
        ['Remove Trailing Empty Lines'] = function()
          require('mini.trailspace').trim_last_lines()
        end,
        ['Remove Trailing Spaces'] = function()
          require('mini.trailspace').trim()
        end,
      })
    end,
    setup = function() require('mini.trailspace').setup() end,
  },
  {
    src = 'https://github.com/nvim-mini/mini.splitjoin',
    cond = function() return ar.get_plugin_cond('mini.splitjoin') end,
    keys = function(load)
      vim.keymap.set({ 'n', 'x' }, '<leader>J', function()
        load()
        local keys =
          vim.api.nvim_replace_termcodes('<leader>J', true, false, true)
        vim.api.nvim_feedkeys(keys, 'mi', false)
      end, { desc = 'splitjoin: toggle' })
    end,
    setup = function()
      require('mini.splitjoin').setup({ mappings = { toggle = '<leader>J' } })
    end,
  },
  {
    src = 'https://github.com/nvim-mini/mini.comment',
    cond = function()
      return ar.get_plugin_cond('mini.comment', ar.plugins.coding)
    end,
    event = 'VeryLazy',
    setup = function()
      require('mini.comment').setup({
        options = {
          custom_commentstring = function()
            if ar.has('nvim-ts-context-commentstring') then
              return require('ts_context_commentstring.internal').calculate_commentstring()
            end
            return vim.bo.commentstring
          end,
        },
      })
    end,
  },
})
