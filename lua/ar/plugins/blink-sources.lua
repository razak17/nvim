local minimal = ar.plugins.minimal

local function get_cond(plugin) return ar.get_plugin_cond(plugin, not minimal) end

return {
  {
    'saghen/blink.cmp',
    optional = true,
    dependencies = {
      {
        'mikavilpas/blink-ripgrep.nvim',
        cond = get_cond('blink-ripgrep.nvim'),
        specs = {
          'saghen/blink.cmp',
          opts = {
            sources = {
              default = { 'ripgrep' },
              providers = {
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
              },
            },
          },
        },
      },
      {
        'moyiz/blink-emoji.nvim',
        cond = get_cond('blink-emoji.nvim'),
        specs = {
          'saghen/blink.cmp',
          opts = {
            sources = {
              default = { 'emoji' },
              providers = {
                emoji = {
                  module = 'blink-emoji',
                  name = '[EMOJI]',
                  score_offset = 15,
                  min_keyword_length = 2,
                  opts = { insert = true },
                },
              },
            },
          },
        },
      },
      {
        'joelazar/blink-calc',
        cond = get_cond('blink-calc'),
        specs = {
          'saghen/blink.cmp',
          opts = {
            sources = {
              default = { 'calc' },
              providers = {
                calc = {
                  module = 'blink-calc',
                  name = '[CALC]',
                  score_offset = 30,
                },
              },
            },
          },
        },
      },
      {
        'mgalliou/blink-cmp-tmux',
        cond = get_cond('blink-cmp-tmux'),
        specs = {
          'saghen/blink.cmp',
          opts = {
            sources = {
              default = { 'tmux' },
              providers = {
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
              },
            },
          },
        },
      },
    },
  },
}
