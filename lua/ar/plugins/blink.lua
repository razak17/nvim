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
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      signature = { window = { border = border } },
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
              { 'item_idx' },
              { 'seperator' },
              { 'label', gap = 1 },
              { 'kind_icon', gap = 2, 'source_name' },
            },
            components = {
              item_idx = {
                text = function(ctx)
                  return ctx.idx == 10 and '0'
                    or ctx.idx >= 10 and ' '
                    or tostring(ctx.idx)
                end,
                highlight = 'comment',
              },
              seperator = {
                text = function() return '│' end,
                highlight = 'comment',
              },
            },
            treesitter = { 'lsp' },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = border },
        },
        list = {
          selection = function(ctx)
            return ctx.mode == 'cmdline' and 'auto_insert' or 'preselect'
          end,
        },
      },
      sources = {
        default = function()
          local node = vim.treesitter.get_node()
          local providers = {
            'lsp',
            'path',
            'snippets',
            'buffer',
            'luasnip',
            'ripgrep',
            'dadbod',
            'nvim-px-to-rem',
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
            if ar_config.ai.enable then table.insert(providers, 2, 'copilot') end
            return providers
          end
        end,
        providers = {
          lsp = {
            enabled = ar.lsp.enable,
            name = '[LSP]',
          },
          path = { name = '[PATH]' },
          snippets = { name = '[SNIP]' },
          buffer = { name = '[BUF]' },
          cmdline = { name = '[CMD]' },
          copilot = {
            enabled = ar_config.ai.enable,
            name = '[CPL]',
            module = 'blink-cmp-copilot',
            score_offset = 100,
            async = true,
            transform_items = function(_, items)
              local CompletionItemKind =
                require('blink.cmp.types').CompletionItemKind
              local kind_idx = #CompletionItemKind + 1
              CompletionItemKind[kind_idx] = 'Copilot'
              for _, item in ipairs(items) do
                item.kind = kind_idx
              end
              return items
            end,
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
            opts = { prefix_min_len = 5 },
          },
          dadbod = { name = '[DB]', module = 'vim_dadbod_completion.blink' },
          ['nvim-px-to-rem'] = {
            module = 'nvim-px-to-rem.integrations.blink',
            name = '[PX2REM]',
          },
        },
        cmdline = function()
          local type = vim.fn.getcmdtype()
          if type == '/' or type == '?' then return { 'buffer' } end
          if type == ':' then return { 'cmdline' } end
          return {}
        end,
      },
      keymap = {
        preset = 'default',
        ['<C-l>'] = { 'snippet_forward', 'fallback' },
        ['<C-h>'] = { 'snippet_backward', 'fallback' },
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-space>'] = {
          'show',
          'show_documentation',
          'hide_documentation',
          'fallback',
        },
        ['<C-y>'] = { 'select_and_accept' },
        ['<A-1>'] = {
          function(cmp) cmp.accept({ index = 1 }) end,
        },
        ['<A-2>'] = {
          function(cmp) cmp.accept({ index = 2 }) end,
        },
        ['<A-3>'] = {
          function(cmp) cmp.accept({ index = 3 }) end,
        },
        ['<A-4>'] = {
          function(cmp) cmp.accept({ index = 4 }) end,
        },
        ['<A-5>'] = {
          function(cmp) cmp.accept({ index = 5 }) end,
        },
        ['<A-6>'] = {
          function(cmp) cmp.accept({ index = 6 }) end,
        },
        ['<A-7>'] = {
          function(cmp) cmp.accept({ index = 7 }) end,
        },
        ['<A-8>'] = {
          function(cmp) cmp.accept({ index = 8 }) end,
        },
        ['<A-9>'] = {
          function(cmp) cmp.accept({ index = 9 }) end,
        },
        ['<A-0>'] = {
          function(cmp) cmp.accept({ index = 10 }) end,
        },
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
            { BlinkCmpDocBorder = { link = 'FloatBorder' } },
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
            { BlinkCmpLabel = { fg = { from = 'StatusLine' } } },
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
        Color = ui.icons.misc.block_alt, -- Use block instead of icon for color items to make swatches more usable
        Copilot = ui.codicons.misc.octoface,
      }, symbols)
      require('blink.cmp').setup(opts)
    end,
    dependencies = {
      'rafamadriz/friendly-snippets',
      'mikavilpas/blink-ripgrep.nvim',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'jsongerber/nvim-px-to-rem',
      { 'giuxtaposition/blink-cmp-copilot', cond = ar_config.ai.enable },
      {
        'saghen/blink.compat',
        version = '*',
        opts = { impersonate_nvim_cmp = true },
      },
    },
  },
}
