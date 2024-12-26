local fmt = string.format
local ui, highlight = ar.ui, ar.highlight
local border, lsp_hls = ui.current.border, ui.lsp.highlights

return {
  {
    'saghen/blink.cmp',
    cond = ar.completion.enable and ar.completion.variant == 'blink',
    event = 'InsertEnter',
    version = '*', -- REQUIRED `version` needed to download pre-built binary
    opts_extend = {
      'sources.completion.enabled_providers',
      'sources.compat',
      'sources.default',
    },
    opts = {
      appearance = {
        -- sets the fallback highlight groups to nvim-cmp's highlight groups
        -- useful for when your theme doesn't support blink.cmp
        -- will be removed in a future release, assuming themes add support
        use_nvim_cmp_as_default = false,
        -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },
      completion = {
        accept = {
          -- experimental auto-brackets support
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          border = border,
          winblend = 0,
          winhighlight = 'NormalFloat:NormalFloat,CursorLine:PmenuSel,NormalFloat:NormalFloat',
          draw = {
            columns = {
              { 'label', gap = 1 },
              { 'kind_icon', gap = 2, 'source_name' },
            },
            treesitter = { 'lsp' },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
      },
      sources = {
        completion = {
          enabled_providers = function(_)
            local node = vim.treesitter.get_node()
            local providers = {
              'lsp',
              'path',
              'snippets',
              'buffer',
              'luasnip',
              'ripgrep',
              -- 'copilot',
              'dadbod',
            }

            if
              node
              and vim.tbl_contains(
                { 'comment', 'line_comment', 'block_comment' },
                node:type()
              )
            then
              return { 'buffer' }
            else
              if ar.ai.enable then table.insert(providers, 2, 'copilot') end
              return providers
            end
          end,
        },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = 'mono',
        },
        signature = {
          enabled = true,
        },
        providers = {
          lsp = { name = '[LSP]' },
          path = { name = '[PATH]' },
          snippets = { name = '[SNIP]' },
          buffer = { name = '[BUF]' },
          copilot = {
            enabled = ar.ai.enable,
            name = '[CPL]',
            module = 'blink-cmp-copilot',
            kind = 'Copilot',
            score_offset = 100,
            async = true,
          },
          luasnip = {
            name = '[SNIP]',
            module = 'blink.compat.source',
            score_offset = -3,
            opts = {
              use_show_condition = false,
              show_autosnippets = true,
            },
          },
          ripgrep = {
            module = 'blink-ripgrep',
            name = '[RG]',
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                item.kind = require('blink.cmp.types').CompletionItemKind.Field
              end
              return items
            end,
            opts = {
              -- the minimum length of the current word to start searching
              -- (if the word is shorter than this, the search will not start)
              prefix_min_len = 5,
              -- The number of lines to show around each match in the preview window
              context_size = 5,
              max_filesize = '1M',
            },
          },
          dadbod = { name = '[DB]', module = 'vim_dadbod_completion.blink' },
        },
      },
      keymap = {
        preset = 'enter',
        ['<C-y>'] = { 'select_and_accept' },
      },
    },
    config = function(_, opts)
      local hl_defs = vim
        .iter(lsp_hls)
        :map(
          function(key, value)
            return {
              [fmt('BlinkCmpKind%s', key)] = { fg = { from = value } },
            }
          end
        )
        :totable()

      highlight.plugin('BlinkCmp', {
        theme = {
          ['onedark'] = vim.tbl_extend('force', hl_defs, {
            { BlinkCmpLabelDescription = { fg = { from = 'MsgSeparator' } } },
            {
              BlinkCmpLabelDeprecated = {
                strikethrough = true,
                inherit = 'Comment',
              },
            },
            {
              BlinkCmpLabelMatch = { fg = { from = 'WildMenu' }, bold = true },
            },
            { BlinkCmpLabelDetail = { fg = { from = 'WildMenu' } } },
            { BlinkCmpLabel = { fg = { from = 'Comment' } } },
            {
              BlinkCmpSource = {
                fg = { from = 'Comment' },
                italic = true,
                bold = true,
              },
            },
          }),
        },
      })

      local symbols = require('lspkind').symbol_map
      opts.appearance = opts.appearance or {}
      opts.appearance.kind_icons = vim.tbl_extend('keep', {
        Color = '██', -- Use block instead of icon for color items to make swatches more usable
      }, symbols)
      require('blink.cmp').setup(opts)
    end,
    dependencies = {
      'rafamadriz/friendly-snippets',
      'mikavilpas/blink-ripgrep.nvim',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      { 'giuxtaposition/blink-cmp-copilot', cond = ar.ai.enable },
      {
        'saghen/blink.compat',
        version = '*',
        opts = { impersonate_nvim_cmp = true },
      },
    },
  },
}
