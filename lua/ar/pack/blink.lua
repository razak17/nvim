local is_blink = ar.config.completion.variant == 'blink'

if not ar.get_plugin_cond('blink.cmp', ar.completion.enable and is_blink) then
  return
end

---@param source table
---@param provider table<string, blink.cmp.SourceConfig>
---@param opts blink.cmp.Config?
vim.g.blink_add_source = function(source, provider, opts)
  opts = opts or {}
  opts.sources = opts.sources or {}
  opts.sources.default = vim.list_extend(opts.sources.default or {}, source)
  opts.sources.providers =
    vim.tbl_deep_extend('force', opts.sources.providers or {}, provider)
  return opts
end

local api = vim.api
local fmt = string.format
local cmp_utils = require('ar.utils.cmp')
local ui = ar.ui
local border, lsp_hls = ui.current.border.default, ui.lsp.highlights

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

ar.add_to_select('command_palette', {
  ['Toggle Blink Auto Show'] = toggle_blink_auto_show,
})

local function get_sources()
  local node = vim.treesitter.get_node()
  local sources = { 'lsp', 'path', 'snippets', 'buffer' }

  if
    node
    and vim.tbl_contains(
      { 'comment', 'line_comment', 'block_comment' },
      node:type()
    )
  then
    return { 'buffer' }
  else
    return sources
  end
end

local function load()
  if ar.snippets then ar.snippets.load() end
  vim.api.nvim_create_autocmd('PackChanged', {
    group = vim.api.nvim_create_augroup('BlinkBuild', { clear = true }),
    callback = function(ev)
      local name, kind = ev.data.spec.name, ev.data.kind
      if name == 'blink.cmp' and (kind == 'install' or kind == 'update') then
        require('blink.cmp').build():pwait()
      end
    end,
  })

  vim.pack.add({
    'https://github.com/saghen/blink.lib',
    'https://github.com/saghen/blink.cmp',
  }, { confirm = false })

  -- require('blink.cmp').build():pwait()

  local function get_opts()
    local sources = get_sources()
    opts = opts or {}
    opts.sources = opts.sources or {}

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = vim.tbl_extend('force', opts, {
      enabled = function()
        local ignored_filetypes = {
          'TelescopePrompt',
          'telescopeprompt',
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
              cmp_utils.has_words_before()
              or api.nvim_get_mode().mode == 'c'
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
    })

    opts.sources.default = vim.list_extend(opts.sources.default or {}, sources)
    opts.sources.providers =
      vim.tbl_extend('force', opts.sources.providers or {}, {
        lsp = {
          enabled = ar.lsp.enable,
          name = '[LSP]',
          score_offset = 35,
          async = true, -- critical
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
            if ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then
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
      })

    return opts
  end

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

  ar.highlight.plugin('BlinkCmp', hl_defs)

  ar.blink_opts = vim.tbl_deep_extend('force', ar.blink_opts or {}, get_opts())

  if
    ar.get_plugin_cond(
      'ecolog.nvim',
      ar.config.shelter.enable and ar.config.shelter.variant == 'ecolog'
    )
  then
    ar.blink_opts = vim.g.blink_add_source({ 'ecolog' }, {
      ecolog = {
        name = '[ECOLOG]',
        module = 'ecolog.integrations.cmp.blink_cmp',
      },
    }, ar.blink_opts)
  end

  local symbols = {}
  if ar.has('lspkind.nvim') then symbols = require('lspkind').symbol_map end
  local ai_icons = ar.ui.codicons.ai
  ar.blink_opts.appearance = ar.blink_opts.appearance or {}
  ar.blink_opts.appearance.kind_icons = vim.tbl_extend('keep', {
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

  if show_index then
    table.insert(ar.blink_opts.completion.menu.draw.columns, 1, { 'item_idx' })
    table.insert(ar.blink_opts.completion.menu.draw.columns, 2, { 'seperator' })
    ar.blink_opts.completion.menu.draw.components = {
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

  local function add(url, opts)
    vim.pack.add({ url }, { confirm = false })
    if opts.sources then
      ar.blink_opts = vim.g.blink_add_source(
        opts.sources.default or {},
        opts.sources.providers or {},
        ar.blink_opts
      )
    end
  end

  if ar.get_plugin_cond('blink-ripgrep.nvim') then
    add('https://github.com/mikavilpas/blink-ripgrep.nvim', {
      sources = {
        default = { 'ripgrep' },
        providers = {
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
        },
      },
    })
  end

  if ar.get_plugin_cond('blink-emoji.nvim') then
    add('https://github.com/moyiz/blink-emoji.nvim', {
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
    })
  end

  if ar.get_plugin_cond('blink-calc') then
    add('https://github.com/joelazar/blink-calc', {
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
    })
  end

  if ar.get_plugin_cond('blink-emoji.blink-cmp-tmux') then
    add('https://github.com/mgalliou/blink-cmp-tmux', {
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
    })
  end

  if ar.get_plugin_cond('blink-cmp-fuzzy-path') then
    add('https://github.com/daliusd/blink-cmp-fuzzy-path', {
      sources = {
        default = { 'fuzzy-path' },
        providers = {
          ['fuzzy-path'] = {
            module = 'blink-cmp-fuzzy-path',
            name = '[FUZZY]',
            score_offset = 0,
            opts = {
              filetypes = { 'markdown', 'json' }, -- optional
            },
          },
        },
      },
    })
  end

  -- HACK: Some blink community sources depend on the old v1 lib that blink shipped
  -- with. Shim in the new `blink.lib` and functions that those community sources need
  -- from the v1 stuff until they're updated.
  -- https://github.com/saghen/blink.cmp/discussions/2502
  package.loaded['blink.cmp.lib.async'] = (function()
    local task = require('blink.lib.task')
    task.empty = task.resolve
    task.on_completion = task.on_resolve
    task.on_failure = task.on_reject
    task.task = task
    return task
  end)()

  if require('ar.pack.lazydev') then
    ar.blink_opts = vim.g.blink_add_source({ 'lazydev' }, {
      lazydev = {
        name = '[LAZYDEV]',
        module = 'lazydev.integrations.blink',
        score_offset = 100, -- show at a higher priority than lsp
      },
    }, opts)
    ar.blink_opts.sources.per_filetype = vim.tbl_deep_extend(
      'force',
      ar.blink_opts.sources.per_filetype or {},
      { lua = { inherit_defaults = true, 'lazydev' } }
    )
  end

  if ar.copilot then ar.blink_opts = ar.copilot.blink(ar.blink_opts) end
  require('blink.cmp').setup(ar.blink_opts)
end

vim.api.nvim_create_autocmd({ 'InsertEnter', 'CmdlineEnter' }, {
  once = true,
  callback = load,
})
