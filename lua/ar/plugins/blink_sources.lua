local minimal = ar.plugins.minimal

local function get_cond(plugin) return ar.get_plugin_cond(plugin, not minimal) end

return {
  {
    'mikavilpas/blink-ripgrep.nvim',
    {
      'saghen/blink.cmp',
      optional = true,
      opts = function(_, opts)
        return get_cond('blink-ripgrep.nvim')
            and vim.g.blink_add_source({ 'ripgrep' }, {
              ripgrep = {
                module = 'blink-ripgrep',
                name = '[RG]',
                transform_items = function(_, items)
                  for _, item in ipairs(items) do
                    item.kind =
                      require('blink.cmp.types').CompletionItemKind.Field
                  end
                  return items
                end,
                opts = { prefix_min_len = 5 },
              },
            }, opts)
          or opts
      end,
    },
  },
  {
    'moyiz/blink-emoji.nvim',
    {
      'saghen/blink.cmp',
      optional = true,
      opts = function(_, opts)
        return get_cond('blink-emoji.nvim')
            and vim.g.blink_add_source({ 'emoji' }, {
              emoji = {
                module = 'blink-emoji',
                name = '[EMOJI]',
                score_offset = 15,
                min_keyword_length = 2,
                opts = { insert = true },
              },
            }, opts)
          or opts
      end,
    },
  },
  {
    'joelazar/blink-calc',
    {
      'saghen/blink.cmp',
      optional = true,
      opts = function(_, opts)
        return get_cond('blink-calc')
            and vim.g.blink_add_source({ 'calc' }, {
              calc = {
                module = 'blink-calc',
                name = '[CALC]',
                score_offset = 30,
              },
            }, opts)
          or opts
      end,
    },
  },
  {
    'mgalliou/blink-cmp-tmux',
    {
      'saghen/blink.cmp',
      optional = true,
      opts = function(_, opts)
        return get_cond('blink-cmp-tmux')
            and vim.g.blink_add_source({ 'tmux' }, {
              tmux = {
                module = 'blink-cmp-tmux',
                name = '[TMUX]',
                opts = {
                  all_panes = false,
                  capture_history = false,
                  triggered_only = false,
                  trigger_chars = { '.' },
                },
              },
            }, opts)
          or opts
      end,
    },
  },
}
