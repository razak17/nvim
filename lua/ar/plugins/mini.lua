local minimal = ar.plugins.minimal

return {
  {
    'echasnovski/mini.extra',
    cond = function() return ar.get_plugin_cond('mini.extra') end,
    config = function() require('mini.extra').setup() end,
  },
  {
    'echasnovski/mini.hipatterns',
    cond = function() return ar.get_plugin_cond('mini.hipatterns') end,
  },
  {
    'echasnovski/mini.bracketed',
    cond = function() return ar.get_plugin_cond('mini.bracketed', not minimal) end,
    event = { 'BufRead', 'BufNewFile' },
    opts = { buffer = { suffix = '' } },
  },
  {
    'echasnovski/mini.trailspace',
    cond = function() return ar.get_plugin_cond('mini.trailspace', not minimal) end,
    init = function()
      local trailspace = require('mini.trailspace')
      ar.add_to_select_menu('command_palette', {
        ['Remove Trailing Empty Lines'] = trailspace.trim_last_lines,
        ['Remove Trailing Spaces'] = trailspace.trim,
      })
    end,
    opts = {},
  },
  {
    'echasnovski/mini.splitjoin',
    keys = { { '<leader>J', desc = 'splitjoin: toggle' } },
    opts = { mappings = { toggle = '<leader>J' } },
  },
  {
    'echasnovski/mini.comment',
    cond = function() return ar.get_plugin_cond('mini.comment') end,
    event = 'VeryLazy',
    opts = {
      options = {
        custom_commentstring = function()
          if ar.is_available('nvim-ts-context-commentstring') then
            return require('ts_context_commentstring.internal').calculate_commentstring()
          end
          return vim.bo.commentstring
        end,
      },
    },
  },
}
