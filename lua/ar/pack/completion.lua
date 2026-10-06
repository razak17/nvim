---@diagnostic disable: redundant-parameter

local is_cmp = ar.config.completion.variant == 'cmp'

if not ar.get_plugin_cond('nvim-cmp', ar.completion.enable and is_cmp) then
  return
end

---@param opts table
---@param config table
vim.g.cmp_add_source = function(opts, config)
  opts = opts or {}
  opts.sources = opts.sources or {}
  if config.source then table.insert(opts.sources, 1, config.source) end
  if config.menu then
    local menu = ar.completion.config.menu
    ar.completion.config.menu = vim.tbl_extend('force', menu, config.menu)
  end
  if config.format then
    local format = ar.completion.config.format
    ar.completion.config.format = vim.tbl_extend('force', format, config.format)
  end
  return opts
end

local fmt = string.format
local cmp_utils = require('ar.utils.cmp')
local ui, highlight = ar.ui, ar.highlight
local border, lsp_hls, ellipsis =
  ui.current.border.default, ui.lsp.highlights, ui.icons.misc.ellipsis

ar.completion.config = vim.tbl_extend('force', ar.completion.config or {}, {
  format = { Color = { icon = ui.icons.misc.block_medium } },
  menu = { Color = '[COLOR]' },
})

local load = function(event)
  if ar.snippets then ar.snippets.load() end
  vim.pack.add({
    'https://github.com/hrsh7th/nvim-cmp',
    'https://github.com/razak17/lspkind.nvim',
  }, { confirm = false })

  local function get_opts()
    local snippet = vim.snippet
    local cmp = require('cmp')
    local types = require('cmp.types')
    local luasnip_avail, luasnip = pcall(require, 'luasnip')
    local symbols = require('lspkind').symbol_map
    local MIN_MENU_WIDTH, MAX_MENU_WIDTH =
      25, math.min(50, math.floor(vim.o.columns * 0.5))

    local function tab(fallback)
      if snippet.active({ direction = 1 }) then return snippet.jump(1) end
      if cmp_utils.has_words_before() and not cmp.visible() then
        return cmp.complete()
      end
      if not cmp.visible() then return fallback() end
      if cmp.visible() then return cmp.select_next_item() end
      if luasnip_avail and luasnip.expand_or_jumpable() then
        return luasnip.expand_or_jump()
      end
      cmp.confirm()
    end

    local function shift_tab(fallback)
      if snippet.active({ direction = -1 }) then return snippet.jump(-1) end
      if cmp_utils.has_words_before() and not cmp.visible() then
        return cmp.complete()
      end
      if not cmp.visible() then return fallback() end
      if cmp.visible() then return cmp.select_prev_item() end
      if luasnip_avail and luasnip.jumpable(-1) then return luasnip.jump(-1) end
    end

    local priority_map = {
      [types.lsp.CompletionItemKind.EnumMember] = 1,
      [types.lsp.CompletionItemKind.Variable] = 2,
      [types.lsp.CompletionItemKind.Text] = 100,
    }

    local kind = function(entry1, entry2)
      local kind1 = entry1:get_kind()
      local kind2 = entry2:get_kind()
      kind1 = priority_map[kind1] or kind1
      kind2 = priority_map[kind2] or kind2
      if kind1 ~= kind2 then
        if kind1 == types.lsp.CompletionItemKind.Snippet then return true end
        if kind2 == types.lsp.CompletionItemKind.Snippet then return false end
        local diff = kind1 - kind2
        if diff < 0 then
          return true
        elseif diff > 0 then
          return false
        end
      end
    end

    local opts = {}

    ---@type cmp.ConfigSchema
    opts = vim.tbl_extend('force', opts, {
      performance = {
        debounce = 0,
        throttle = 0,
        fetching_timeout = 2000,
      },
      preselect = cmp.PreselectMode.None,
      window = {
        completion = cmp.config.window.bordered({
          border = border,
          winhighlight = 'NormalFloat:NormalFloat,CursorLine:PmenuSel,NormalFloat:NormalFloat',
        }),
        documentation = cmp.config.window.bordered({
          border = border,
          winhighlight = 'NormalFloat:NormalFloat',
        }),
      },
      sorting = {
        priority_weight = 100,
        comparators = {
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          kind,
          cmp.config.compare.recently_used,
          cmp.config.compare.locality,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      },
      matching = {
        disallow_symbol_nonprefix_matching = true,
        disallow_fuzzy_matching = false,
        disallow_fullfuzzy_matching = true,
        disallow_partial_fuzzy_matching = true,
        disallow_partial_matching = true,
        disallow_prefix_unmatching = false,
      },
      mapping = {
        ['<C-k>'] = cmp.mapping.select_prev_item(),
        ['<C-j>'] = cmp.mapping.select_next_item(),
        ['<C-n>'] = cmp.mapping(tab, { 'i', 's' }),
        ['<C-p>'] = cmp.mapping(shift_tab, { 'i', 's' }),
        ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
        ['<Tab>'] = cmp.mapping(tab, { 'i', 's', 'c' }),
        ['<S-Tab>'] = cmp.mapping(shift_tab, { 'i', 's', 'c' }),
        ['<C-q>'] = cmp.mapping({
          i = cmp.mapping.abort(),
          c = cmp.mapping.close(),
        }),
        ['<C-u>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping(function(fallback)
          -- use the internal non-blocking call to check if cmp is visible
          if cmp.core.view:visible() then
            cmp.confirm({ select = true })
          else
            fallback()
          end
        end),
      },
      formatting = {
        expandable_indicator = true,
        deprecated = true,
        fields = { 'abbr', 'kind', 'menu' },
        format = function(entry, item)
          item.menu = (ar.completion.config.menu)[entry.source.name]

          local label, length = item.abbr, vim.api.nvim_strwidth(item.abbr)
          local function format_icon(icon) return fmt('%s ', icon) end
          vim.o.pumblend = 0

          if length < MIN_MENU_WIDTH then
            item.abbr = label .. string.rep(' ', MIN_MENU_WIDTH - length)
          end
          if #item.abbr >= MAX_MENU_WIDTH then
            item.abbr = item.abbr:sub(1, MAX_MENU_WIDTH) .. ellipsis
          end

          if
            not ar.completion.config.format[entry.source.name]
            and item.kind ~= 'Color'
          then
            if ar.config.completion.icons == 'mini.icons' then
              local MiniIcons = require('mini.icons')
              local icon, hl = MiniIcons.get('lsp', item.kind)
              item.kind = icon
              item.kind_hl_group = hl
            elseif ar.config.completion.icons == 'lspkind' then
              item.kind = format_icon(symbols[item.kind])
            end
          end

          local format = ar.completion.config.format
          local config = format[entry.source.name]
          if entry.source.name == 'minuet' then
            config = format[entry.completion_item.cmp.kind_text]
          end

          if config then
            if config.icon then item.kind = format_icon(config.icon) end
            if config.hl then item.kind_hl_group = config.hl end
          end

          if item.kind == 'Color' then
            vim.o.pumblend = 3
            item.menu = '[COLOR]'
            if item.kind == 'Color' then
              local entry_cmp = entry.completion_item
              if type(entry_cmp.documentation) == 'string' then
                item = cmp_utils.get_color(entry, item)
              else
                item.kind = format_icon(symbols[item.kind])
              end
            end
          end
          return item
        end,
      },
    })

    opts = vim.g.cmp_add_source(opts, {
      source = {
        name = 'snippets',
        priority = 900,
        group_index = 1,
      },
      menu = { snippets = '[SNIP]' },
    })

    if opts.snippet == nil then
      opts.snippet = {
        expand = function(args) vim.snippet.expand(args.body) end,
      }
    end

    return opts
  end

  local hl_defs = vim
    .iter(lsp_hls)
    :map(
      function(key, value)
        return {
          [fmt('CmpItemKind%s', key)] = { fg = { from = value } },
        }
      end
    )
    :totable()
  hl_defs = vim.tbl_extend('force', hl_defs, {
    { CmpItemAbbrMatch = { link = 'PmenuMatch' } },
    { CmpItemAbbrMatchFuzzy = { link = 'PmenuMatch' } },
    { CmpItemMenu = { link = 'PmenuKind' } },
    { CmpItemAbbrDeprecated = { link = 'PmenuDeprecated' } },
  })

  highlight.plugin('Cmp', hl_defs)
  highlight.plugin('CmpOverrides', {
    theme = {
      ['onedark'] = {
        { CmpItemKindNerdFont = { fg = { from = 'Directory' } } },
        { CmpItemKindLab = { fg = { from = 'Directory' } } },
        { CmpItemKindDynamic = { fg = { from = 'Directory' } } },
      },
    },
  })

  ar.cmp_opts = vim.tbl_deep_extend('force', ar.cmp_opts or {}, get_opts())

  if ar.snippets then
    vim.pack.add(
      { 'https://github.com/saadparwaiz1/cmp_luasnip' },
      { confirm = false }
    )
    ar.cmp_opts.snippet = {
      expand = function(args) require('luasnip').lsp_expand(args.body) end,
    }
    ar.cmp_opts = vim.g.cmp_add_source(ar.cmp_opts, {
      source = { name = 'luasnip', priority = 900, group_index = 1 },
      menu = { luasnip = '[LSNIP]' },
    })
  end

  local enabled = {}

  local function get_cond(plugin) return ar.get_plugin_cond(plugin, is_cmp) end

  local function add(url, name, config)
    vim.pack.add({ url }, { confirm = false })
    ar.cmp_opts = vim.g.cmp_add_source(ar.cmp_opts, config or {})
    enabled[name] = true
  end

  if get_cond('cmp-path') then
    add('https://github.com/hrsh7th/cmp-path', 'cmp-path', {
      source = {
        name = 'path',
        priority = 5,
        group_index = 1,
        max_item_count = 3,
      },
      menu = { path = '[PATH]' },
    })
  end

  if get_cond('cmp-async-path') then
    add('https://codeberg.org/FelipeLema/cmp-async-path', 'cmp-async-path', {
      source = {
        name = 'async_path',
        priority = 5,
        group_index = 1,
        max_item_count = 3,
      },
      menu = { async_path = '[APATH]' },
    })
  end

  if get_cond('cmp-rg') then
    add('https://github.com/lukas-reineke/cmp-rg', 'cmp-rg', {
      source = {
        name = 'rg',
        priority = 4,
        keyword_length = ar.lsp.enable and 8 or 4,
        option = { additional_arguments = '--max-depth 8' },
        group_index = 1,
      },
      menu = { rg = '[RG]' },
    })
  end

  if get_cond('cmp-buffer') then
    add('https://github.com/hrsh7th/cmp-buffer', 'cmp-buffer', {
      source = {
        name = 'buffer',
        priority = 4,
        option = {
          get_bufnrs = function() return vim.api.nvim_list_bufs() end,
        },
        group_index = 1,
        max_item_count = 3,
      },
      menu = { buffer = '[BUF]' },
    })
  end

  if get_cond('nvim-cmp-buffer-lines') then
    add(
      'https://github.com/amarakon/nvim-cmp-buffer-lines',
      'nvim-cmp-buffer-lines',
      {
        source = {
          name = 'buffer-lines',
          priority = 4,
          group_index = 1,
          max_item_count = 3,
        },
        menu = { ['buffer-lines'] = '[BUFL]' },
      }
    )
  end

  if get_cond('cmp-cmdline-history') then
    add(
      'https://github.com/dmitmel/cmp-cmdline-history',
      'cmp-cmdline-history',
      {
        menu = { cmdline_history = '[CHIST]' },
      }
    )
  end

  if ar.lsp.enable then
    add(
      'https://github.com/hrsh7th/cmp-nvim-lsp-document-symbol',
      'cmp-nvim-lsp-document-symbol'
    )
  end

  if get_cond('cmp-spell') then
    local filetypes =
      { 'gitcommit', 'NeogitCommitMessage', 'markdown', 'norg', 'org' }
    local spell_loaded = false
    local function load_spell()
      if spell_loaded then return end
      add('https://github.com/f3fora/cmp-spell', 'cmp-spell', {
        menu = { spell = '[SPELL]' },
      })
      local sources = vim.deepcopy(ar.cmp_opts.sources or {})
      table.insert(
        sources,
        1,
        { name = 'spell', max_item_count = 10, group_index = 2 }
      )
      require('cmp').setup.filetype(filetypes, { sources = sources })
      spell_loaded = true
    end
    vim.api.nvim_create_autocmd('FileType', {
      pattern = filetypes,
      once = true,
      callback = load_spell,
    })
    if vim.tbl_contains(filetypes, vim.bo.filetype) then load_spell() end
  end

  if get_cond('cmp-tmux') then
    add('https://github.com/andersevenrud/cmp-tmux', 'cmp-tmux', {
      source = {
        name = 'tmux',
        priority = 4,
        group_index = 1,
        max_item_count = 5,
        option = {
          -- Source from all panes in session instead of adjacent panes
          all_panes = true,
          -- Completion popup label
          label = '[TMUX]',
          -- Trigger character
          trigger_characters = { '.' },
          -- Specify trigger characters for filetype(s)
          -- { filetype = { '.' } }
          trigger_characters_ft = {},
          -- Keyword patch mattern
          keyword_pattern = [[\w\+]],
          -- Capture full pane history
          -- `false`: show completion suggestion from text in the visible pane (default)
          -- `true`: show completion suggestion from text starting from the beginning of the pane history.
          --         This works by passing `-S -` flag to `tmux capture-pane` command. See `man tmux` for details.
          capture_history = true,
        },
      },
      menu = { tmux = '[TMUX]' },
    })
  end

  if get_cond('cmp-dotenv') then
    add('https://github.com/SergioRibera/cmp-dotenv', 'cmp-dotenv', {
      source = {
        name = 'dotenv',
        group_index = 4,
        max_item_count = 5,
      },
      menu = { dotenv = '[DOTENV]' },
    })
  end

  if get_cond('cmp-natdat') then
    add('https://github.com/Gelio/cmp-natdat', 'cmp-natdat', {
      source = {
        name = 'natdat',
        priority = 3,
        keyword_length = 3,
        group_index = 1,
      },
      menu = { natdat = '[NATDAT]' },
      format = {
        natdat = {
          icon = ui.codicons.misc.calendar,
          hl = 'CmpItemKindDynamic',
        },
      },
    })
  end

  if get_cond('cmp-emoji') then
    add('https://github.com/hrsh7th/cmp-emoji', 'cmp-emoji', {
      source = {
        name = 'emoji',
        priority = 3,
        group_index = 1,
        max_item_count = 5,
      },
      menu = { emoji = '[EMOJI]' },
      format = {
        emoji = {
          icon = ui.codicons.misc.smiley,
          hl = 'CmpItemKindEmoji',
        },
      },
    })
  end

  if get_cond('cmp-nerdfonts') then
    add('fazibear/cmp-nerdfonts', 'cmp-nerdfonts', {
      source = {
        name = 'nerdfonts',
        group_index = 3,
        max_item_count = 5,
      },
      menu = { nerdfonts = '[NF]' },
      format = {
        nerdfonts = {
          icon = ui.codicons.misc.nerd_font,
          hl = 'CmpItemKindNerdFont',
        },
      },
    })
  end

  if
    ar.get_plugin_cond(
      'cmp-dictionary',
      ar.plugins.overrides.dict.enable and not ar.plugins.minimal
    )
  then
    add('uga-rosa/cmp-dictionary', 'cmp-dictionary', {
      menu = { dictionary = '[DICT]' },
    })
    local en_dict =
      join_paths(vim.fn.stdpath('data'), 'site', 'spell', 'en.dict')
    require('cmp_dictionary').setup({ paths = { en_dict } })
  end

  if get_cond('cmp-cmdline') then
    add('https://github.com/hrsh7th/cmp-cmdline', 'cmp-cmdline', {
      menu = { cmdline = '[CMD]' },
    })
    vim.o.wildmode = ''
    local cmp = require('cmp')
    local search = {}
    for _, name in ipairs({
      'nvim_lsp_document_symbol',
      'buffer',
      'buffer-lines',
    }) do
      if enabled[name] then
        table.insert(search, {
          name = name,
          group_index = #search + 1,
          option = name == 'buffer' and { keyword_pattern = [[\k\+]] } or nil,
        })
      end
    end
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = search,
    })
    local command = {
      {
        name = 'cmdline',
        keyword_pattern = [=[[^[:blank:]\!]*]=],
        max_item_count = 3,
      },
    }
    for _, name in ipairs({ 'async_path', 'path' }) do
      if enabled[name] then
        table.insert(command, { name = name, max_item_count = 5 })
      end
    end
    if enabled.cmdline_history then
      table.insert(
        command,
        { name = 'cmdline_history', priority = 10, max_item_count = 3 }
      )
    end
    cmp.setup.cmdline(
      ':',
      { mapping = cmp.mapping.preset.cmdline(), sources = command }
    )
  end

  if require('ar.pack.crates') then
    ar.cmp_opts = vim.g.cmp_add_source(ar.cmp_opts, {
      source = {
        name = 'luasnip',
        priority = 900,
        group_index = 1,
      },
      menu = { crates = '[CRT]' },
      format = {
        crates = {
          icon = ar.ui.codicons.misc.package,
          hl = 'CmpItemKindDynamic',
        },
      },
    })
  end

  if require('ar.pack.lazydev') then
    ar.cmp_opts = vim.g.cmp_add_source(ar.cmp_opts, {
      source = { name = 'lazydev', group_index = 0 },
      menu = { lazydev = '[LAZYDEV]' },
    })
  end

  if ar.copilot then ar.cmp_opts = ar.copilot.cmp(ar.cmp_opts) end
  require('cmp').setup(ar.cmp_opts)
  ar.command('CmpInfo', function() require('cmp').status() end, {})
  -- cmp's handlers were registered after the event that loaded it.
  require('cmp.utils.autocmd').emit(event.event, event)
end

vim.api.nvim_create_autocmd({ 'InsertEnter', 'CmdlineEnter' }, {
  once = true,
  callback = load,
})
