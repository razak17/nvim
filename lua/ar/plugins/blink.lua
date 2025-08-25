local api = vim.api
local fmt = string.format
local cmp_utils = require('ar.utils.cmp')
local ui = ar.ui
local border, lsp_hls = ui.current.border, ui.lsp.highlights
local minimal = ar.plugins.minimal
local is_avail = ar.is_available
local is_blink = ar_config.completion.variant == 'blink'
local ai_models = ar_config.ai.models
local ai_cmp = ar_config.ai.completion
local which_ai_cmp = ai_cmp.variant
local is_copilot = ai_models.copilot
  and which_ai_cmp == 'copilot'
  and is_avail('copilot.lua')
local is_minuet = ai_models.gemini
  and which_ai_cmp == 'minuet'
  and is_avail('minuet-ai.nvim')

local show_index = false
_G.auto_show = true

local function toggle_blink_auto_show()
  _G.auto_show = not _G.auto_show
  vim.notify(
    fmt('Autocompletion is now %s', _G.auto_show and 'enabled' or 'disabled'),
    vim.log.levels.INFO,
    { title = 'Blink Auto Show' }
  )
end

ar.add_to_select_menu('command_palette', {
  ['Toggle Blink Auto Show'] = toggle_blink_auto_show,
})

return {
  {
    'saghen/blink.cmp',
    cond = ar.completion.enable and not minimal and is_blink,
    event = { 'InsertEnter', 'CmdlineEnter' },
    version = '*', -- REQUIRED `version` needed to download pre-built binary
    opts_extend = {
      'sources.completion.enabled_providers',
      -- 'sources.compat',
      'sources.default',
      'cmdline.sources',
      'term.sources',
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      enabled = function()
        local ignored_filetypes = {
          'TelescopePrompt',
          'minifiles',
          'snacks_picker_input',
          'neo-tree-popup',
          'dropbar_menu_fzf',
        }
        local filetype = vim.bo[0].filetype
        return not vim.tbl_contains(ignored_filetypes, filetype)
      end,
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      signature = { window = { border = border } },
      cmdline = {
        keymap = {
          preset = 'cmdline',
          -- recommended, as the default keymap will only show and select the next item
          ['<Tab>'] = { 'show', 'select_next' },
          ['<S-Tab>'] = { 'show', 'select_prev' },
          ['<CR>'] = { 'accept_and_enter', 'fallback' },
        },
        enabled = true,
        completion = {
          ghost_text = { enabled = false },
          list = { selection = { preselect = false, auto_insert = true } },
          menu = {
            auto_show = function(ctx)
              local type = vim.fn.getcmdtype()
              if ctx.mode == 'cmdline' then
                return type == ':' or type == '@'
              end
              return false
            end,
          },
        },
      },
      completion = {
        accept = {
          -- experimental auto-brackets support
          auto_brackets = { enabled = true },
        },
        -- Recommended to avoid unnecessary request
        trigger = { prefetch_on_insert = false },
        menu = {
          auto_show = function() return _G.auto_show end,
          border = border,
          winblend = 0,
          winhighlight = 'NormalFloat:NormalFloat,CursorLine:PmenuSel,NormalFloat:NormalFloat',
          draw = {
            columns = {
              { 'label', gap = 1 },
              { 'kind_icon', gap = 2, 'source_name' },
            },
            components = {
              kind_icon = {
                text = function(ctx)
                  local data = ctx.source_id == 'codecompanion'
                    and ctx.item.data
                  if data then
                    return data.type == 'variable' and ''
                      or data.type == 'tool' and '󱁤'
                      or '󰿠'
                  end
                  local icon = ctx.kind_icon
                  if ctx.kind == 'Color' then
                    icon = fmt('%s ', ui.icons.misc.block_medium)
                  end
                  return icon .. ctx.icon_gap
                end,
                highlight = function(ctx)
                  local hl = 'BlinkCmpKind' .. ctx.kind
                  local color_item = cmp_utils.get_color(
                    ctx.item.documentation,
                    { kind = ctx.kind }
                  )
                  if color_item and color_item.kind_hl_group then
                    hl = color_item.kind_hl_group
                  end
                  return hl
                end,
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
        ghost_text = { enabled = false },
        list = { selection = { preselect = false, auto_insert = true } },
      },
      sources = {
        default = function()
          local node = vim.treesitter.get_node()
          local sources = {
            'lsp',
            'path',
            'snippets',
            'buffer',
            'ripgrep',
            'emoji',
            'tmux',
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
            if ar.ai.enable then
              if is_copilot then table.insert(sources, 'copilot') end
              if is_minuet then table.insert(sources, 'minuet') end
              if is_copilot then
                table.insert(sources, 'avante_commands')
                table.insert(sources, 'avante_mentions')
                table.insert(sources, 'avante_files')
              end
              if is_avail('codecompanion.nvim') then
                table.insert(sources, 'codecompanion')
              end
            end
            if not minimal then
              table.insert(sources, 'nvim-px-to-rem')
              if is_avail('vim-dadbod-completion') then
                table.insert(sources, 'dadbod')
              end
              if
                ar_config.shelter.variant == 'ecolog'
                and is_avail('ecolog.nvim')
              then
                table.insert(sources, 'ecolog')
              end
            end
            return sources
          end
        end,
        providers = {
          lsp = {
            enabled = ar.lsp.enable,
            name = '[LSP]',
            score_offset = 35,
          },
          path = {
            name = '[PATH]',
            score_offset = 25,
            opts = { show_hidden_files_by_default = true },
          },
          buffer = { name = '[BUF]' },
          cmdline = {
            name = '[CMD]',
            min_keyword_length = function(ctx)
              -- when typing a command, only show when the keyword is 3 characters or longer
              if
                ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil
              then
                return 3
              end
              return 0
            end,
          },
          snippets = {
            enabled = true,
            name = '[SNIP]',
            max_items = 15,
            module = 'blink.cmp.sources.snippets',
            score_offset = 20,
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
          emoji = {
            module = 'blink-emoji',
            name = '[EMOJI]',
            score_offset = 15,
            min_keyword_length = 2,
            opts = { insert = true },
          },
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
      keymap = {
        preset = 'default',
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-n>'] = { 'select_next', 'show' },
        ['<C-p>'] = { 'select_prev', 'show' },
        ['<C-j>'] = { 'select_next', 'show' },
        ['<C-k>'] = { 'select_prev', 'show' },
        ['<C-space>'] = {
          'show',
          'show_documentation',
          'hide_documentation',
          'fallback',
        },
        ['<Tab>'] = {
          'select_next',
          'snippet_forward',
          function(cmp)
            if
              cmp_utils.has_words_before() or api.nvim_get_mode().mode == 'c'
            then
              return cmp.show()
            end
          end,
          'fallback',
        },
        ['<S-Tab>'] = {
          'select_prev',
          'snippet_backward',
          function(cmp)
            if api.nvim_get_mode().mode == 'c' then return cmp.show() end
          end,
          'fallback',
        },
        ['<A-1>'] = { function(cmp) cmp.accept({ index = 1 }) end },
        ['<A-2>'] = { function(cmp) cmp.accept({ index = 2 }) end },
        ['<A-3>'] = { function(cmp) cmp.accept({ index = 3 }) end },
        ['<A-4>'] = { function(cmp) cmp.accept({ index = 4 }) end },
        ['<A-5>'] = { function(cmp) cmp.accept({ index = 5 }) end },
        ['<A-6>'] = { function(cmp) cmp.accept({ index = 6 }) end },
        ['<A-7>'] = { function(cmp) cmp.accept({ index = 7 }) end },
        ['<A-8>'] = { function(cmp) cmp.accept({ index = 8 }) end },
        ['<A-9>'] = { function(cmp) cmp.accept({ index = 9 }) end },
        ['<A-0>'] = { function(cmp) cmp.accept({ index = 10 }) end },
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

      ar.highlight.plugin('BlinkCmp', {
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
      local ai_icons = ar.ui.codicons.ai
      opts.appearance = opts.appearance or {}
      opts.appearance.kind_icons = vim.tbl_extend('keep', {
        Color = ui.icons.misc.block_alt, -- Use block instead of icon for color items to make swatches more usable
        Copilot = ui.codicons.misc.octoface,
        claude = ai_icons.claude,
        codestral = ai_icons.codestral,
        gemini = ai_icons.gemini,
        openai = ai_icons.openai,
        Groq = ai_icons.groq,
        Openrouter = ai_icons.open_router,
        Ollama = ai_icons.ollama,
        ['Llama.cpp'] = ai_icons.llama,
        Deepseek = ai_icons.deepseek,
      }, symbols)

      if not minimal then
        if is_avail('LuaSnip') then
          opts.snippets = {
            preset = 'luasnip',
            expand = function(snippet) require('luasnip').lsp_expand(snippet) end,
            active = function(filter)
              if filter and filter.direction then
                return require('luasnip').jumpable(filter.direction)
              end
              return require('luasnip').in_snippet()
            end,
            jump = function(direction) require('luasnip').jump(direction) end,
          }
        end
        opts.sources.providers['nvim-px-to-rem'] = {
          module = 'nvim-px-to-rem.integrations.blink',
          name = '[PX2REM]',
        }
      end

      if ar.ai.enable then
        if is_copilot then
          opts.sources.providers.copilot = {
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
          }
        end

        if is_minuet then
          opts.sources.providers.minuet = {
            enabled = function()
              return not vim.tbl_contains(
                ar_config.ai.ignored_filetypes,
                vim.bo.ft
              )
            end,
            name = '[MINUET]',
            module = 'minuet.blink',
            score_offset = 100,
            transform_items = function(_, items)
              local CompletionItemKind =
                require('blink.cmp.types').CompletionItemKind
              local kind_idx = #CompletionItemKind + 1
              CompletionItemKind[kind_idx] = 'Minuet'
              for _, item in ipairs(items) do
                item.kind = kind_idx
              end
              return items
            end,
          }
          opts.keymap['<A-y>'] = require('minuet').make_blink_map()
        end

        opts.sources.providers.codecompanion = {
          name = '[CC]',
          module = 'codecompanion.providers.completion.blink',
          score_offset = 100,
          transform_items = function(_, items)
            local CompletionItemKind =
              require('blink.cmp.types').CompletionItemKind
            local kind_idx = #CompletionItemKind + 1
            CompletionItemKind[kind_idx] = 'CodeCompanion'
            for _, item in ipairs(items) do
              item.kind = kind_idx
            end
            return items
          end,
        }
        opts.sources.providers.avante_commands = {
          name = 'avante_commands',
          module = 'blink.compat.source',
          score_offset = 90, -- show at a higher priority than lsp
          opts = {},
        }
        opts.sources.providers.avante_files = {
          name = 'avante_files',
          module = 'blink.compat.source',
          score_offset = 100, -- show at a higher priority than lsp
          opts = {},
        }
        opts.sources.providers.avante_mentions = {
          name = 'avante_mentions',
          module = 'blink.compat.source',
          score_offset = 1000, -- show at a higher priority than lsp
          opts = {},
        }
      end
      if is_avail('vim-dadbod-completion') then
        opts.sources.providers.dadbod =
          { name = '[DB]', module = 'vim_dadbod_completion.blink' }
      end

      if
        not minimal
        and ar_config.shelter.variant == 'ecolog'
        and is_avail('ecolog.nvim')
      then
        opts.sources.providers.ecolog = {
          name = '[ECOLOG]',
          module = 'ecolog.integrations.cmp.blink_cmp',
        }
      end

      if show_index then
        table.insert(opts.completion.menu.draw.columns, 1, { 'item_idx' })
        table.insert(opts.completion.menu.draw.columns, 2, { 'seperator' })
        opts.completion.menu.draw.components = {
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
        }
      end

      require('blink.cmp').setup(opts)
    end,
    dependencies = {
      'mikavilpas/blink-ripgrep.nvim',
      'jsongerber/nvim-px-to-rem',
      'moyiz/blink-emoji.nvim',
      'mgalliou/blink-cmp-tmux',
      {
        'giuxtaposition/blink-cmp-copilot',
        cond = not minimal and is_copilot,
      },
      {
        'saghen/blink.compat',
        opts = {},
      },
    },
  },
}
