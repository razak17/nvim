local minimal = ar.plugins.minimal
local coding = ar.plugins.coding

return {
  {
    'nvim-mini/mini.extra',
    cond = function() return ar.get_plugin_cond('mini.extra') end,
    config = function() require('mini.extra').setup() end,
  },
  {
    'nvim-mini/mini.hipatterns',
    cond = function() return ar.get_plugin_cond('mini.hipatterns') end,
  },
  {
    'nvim-mini/mini.bracketed',
    cond = function() return ar.get_plugin_cond('mini.bracketed', not minimal) end,
    event = { 'BufRead', 'BufNewFile' },
    opts = { buffer = { suffix = '' } },
  },
  {
    'nvim-mini/mini.trailspace',
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
    'nvim-mini/mini.splitjoin',
    keys = { { '<leader>J', desc = 'splitjoin: toggle' } },
    opts = { mappings = { toggle = '<leader>J' } },
  },
  {
    'nvim-mini/mini.comment',
    cond = function()
      local condition = minimal and coding
      return ar.get_plugin_cond('mini.comment', condition)
    end,
    event = 'VeryLazy',
    opts = {
      options = {
        custom_commentstring = function()
          if ar.has('nvim-ts-context-commentstring') then
            return require('ts_context_commentstring.internal').calculate_commentstring()
          end
          return vim.bo.commentstring
        end,
      },
    },
  },
}
