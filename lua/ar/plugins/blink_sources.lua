local minimal = ar.plugins.minimal

local function get_opts(plugin, source, provider, opts)
  local function get_cond() return ar.get_plugin_cond(plugin, not minimal) end
  if not get_cond() then return opts end
  opts = opts or {}
  opts.sources = opts.sources or {}
  opts.sources.default = vim.list_extend(opts.sources.default or {}, { source })
  opts.sources.providers =
    vim.tbl_deep_extend('force', opts.sources.providers or {}, provider)
  return opts
end

return {
  {
    'mikavilpas/blink-ripgrep.nvim',
    {
      'saghen/blink.cmp',
      optional = true,
      opts = function(_, opts)
        return get_opts('blink-ripgrep.nvim', 'ripgrep', {
          ripgrep = {
            module = 'blink-ripgrep',
            name = '[RG]',
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                item.kind = require('blink.cmp.types').CompletionItemKind.Field
              end
              return items
            end,
            opts = { prefix_min_len = 5 },
          },
        }, opts)
      end,
    },
  },
  {
    'moyiz/blink-emoji.nvim',
    {
      'saghen/blink.cmp',
      optional = true,
      opts = function(_, opts)
        return get_opts('blink-emoji.nvim', 'emoji', {
          emoji = {
            module = 'blink-emoji',
            name = '[EMOJI]',
            score_offset = 15,
            min_keyword_length = 2,
            opts = { insert = true },
          },
        }, opts)
      end,
    },
  },
  {
    'mgalliou/blink-cmp-tmux',
    {
      'saghen/blink.cmp',
      optional = true,
      opts = function(_, opts)
        return get_opts('blink-cmp-tmux', 'tmux', {
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
      end,
    },
  },
}
