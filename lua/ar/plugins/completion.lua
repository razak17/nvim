local api, fn, fmt = vim.api, vim.fn, string.format
local cmp_utils = require('ar.utils.cmp')
local ui, highlight = ar.ui, ar.highlight
local border, lsp_hls, ellipsis =
  ui.current.border, ui.lsp.highlights, ui.icons.misc.ellipsis
local minimal = ar.plugins.minimal
local codicons = ui.codicons
local ai_icons = codicons.ai
local is_cmp = ar_config.completion.variant == 'cmp'

ar.completion.config = {
  format = {
    emoji = { icon = codicons.misc.smiley, hl = 'CmpItemKindEmoji' },
    ['lab.quick_data'] = { icon = ui.icons.misc.beaker, hl = 'CmpItemKindLab' },
    natdat = { icon = codicons.misc.calendar, hl = 'CmpItemKindDynamic' },
    crates = { icon = codicons.misc.package, hl = 'CmpItemKindDynamic' },
    copilot = { icon = codicons.misc.octoface, hl = 'CmpItemKindCopilot' },
    codecompanion_tools = { icon = codicons.misc.robot_alt },
    codecompanion_slash_commands = { icon = codicons.misc.robot_alt },
    nerdfonts = { icon = codicons.misc.nerd_font, hl = 'CmpItemKindNerdFont' },
    minuet = { icon = ai_icons.minuet, hl = 'CmpItemKindDynamic' },
    nvim_px_to_rem = { icon = codicons.misc.hash, hl = 'CmpItemKindNerdFont' },
    Color = { icon = ui.icons.misc.block_medium },
    claude = { icon = ai_icons.claude },
    codestral = { icon = ai_icons.codestral },
    gemini = { icon = ai_icons.gemini },
    openai = { icon = ai_icons.openai },
    Groq = { icon = ai_icons.groq },
    Openrouter = { icon = ai_icons.open_router },
    Ollama = { icon = ai_icons.ollama },
    ['Llama.cpp'] = { icon = ai_icons.llama },
    Deepseek = { icon = ai_icons.deepseek },
  },
  menu = {
    Color = '[COLOR]',
    copilot = '[CPL]',
    minuet = '[MINUET]',
    nvim_lsp = '[LSP]',
    luasnip = '[LSNIP]',
    snippets = '[SNIP]',
    emoji = '[EMOJI]',
    path = '[PATH]',
    async_path = '[PATH]',
    neorg = '[NEORG]',
    buffer = '[BUF]',
    spell = '[SPELL]',
    dictionary = '[DICT]',
    rg = '[RG]',
    norg = '[NORG]',
    ['render-markdown'] = '[RMD]',
    cmdline = '[CMD]',
    cmdline_history = '[HIST]',
    crates = '[CRT]',
    treesitter = '[TS]',
    ['buffer-lines'] = '[BUFL]',
    ['lab.quick_data'] = '[LAB]',
    nerdfonts = '[NF]',
    natdat = '[NATDAT]',
    nvim_px_to_rem = '[PX2REM]',
    ['vim-dadbod-completion'] = '[DB]',
    dotenv = '[DOTENV]',
    ecolog = '[ECOLOG]',
    codecompanion_tools = '[CC]',
    codecompanion_slash_commands = '[CC]',
  },
}

return {
  {
    'hrsh7th/nvim-cmp',
    cond = ar.completion.enable and not minimal and is_cmp,
    event = { 'InsertEnter', 'CmdlineEnter' },
    opts = function(_, opts)
      local snippet = vim.snippet
      local cmp = require('cmp')
      local types = require('cmp.types')
      local luasnip_avail, luasnip = pcall(require, 'luasnip')
      local symbols = require('lspkind').symbol_map
      local MIN_MENU_WIDTH, MAX_MENU_WIDTH =
        25, math.min(50, math.floor(vim.o.columns * 0.5))

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

      highlight.plugin('Cmp', {
        theme = {
          ['onedark'] = vim.tbl_extend('force', hl_defs, {
            { CmpItemAbbr = { fg = { from = 'MsgSeparator' } } },
            {
              CmpItemAbbrDeprecated = {
                strikethrough = true,
                inherit = 'Comment',
              },
            },
            { CmpItemAbbrMatch = { fg = { from = 'WildMenu' }, bold = true } },
            { CmpItemAbbrMatchFuzzy = { fg = { from = 'WildMenu' } } },
            {
              CmpItemMenu = {
                fg = { from = 'Comment' },
                italic = true,
                bold = true,
              },
            },
            { CmpItemKindNerdFont = { fg = { from = 'Directory' } } },
            { CmpItemKindLab = { fg = { from = 'Directory' } } },
            { CmpItemKindDynamic = { fg = { from = 'Directory' } } },
          }),
        },
      })

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
        if luasnip_avail and luasnip.jumpable(-1) then
          return luasnip.jump(-1)
        end
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
        -- snippet = {
        --   expand = function(args) vim.snippet.expand(args.body) end,
        -- },
        mapping = {
          ['<C-k>'] = cmp.mapping.select_prev_item(),
          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<C-n>'] = cmp.mapping(tab, { 'i', 's', 'c' }),
          ['<C-p>'] = cmp.mapping(shift_tab, { 'i', 's', 'c' }),
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

            local label, length = item.abbr, api.nvim_strwidth(item.abbr)
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
              if ar_config.completion.icons == 'mini.icons' then
                local MiniIcons = require('mini.icons')
                local icon, hl = MiniIcons.get('lsp', item.kind)
                item.kind = icon
                item.kind_hl_group = hl
              elseif ar_config.completion.icons == 'lspkind' then
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
        sources = {
          { name = 'nvim_lsp', priority = 1000, group_index = 1 },
          { name = 'snippets', priority = 900, group_index = 1 },
          {
            name = 'lab.quick_data',
            priority = 6,
            max_item_count = 10,
            group_index = 1,
          },
          { name = 'path', priority = 5, group_index = 1 },
          { name = 'async_path', priority = 5, group_index = 1 },
          {
            name = 'buffer',
            priority = 4,
            options = {
              get_bufnrs = function() return api.nvim_list_bufs() end,
            },
            group_index = 1,
          },
          {
            name = 'rg',
            priority = 4,
            keyword_length = ar.lsp.enable and 8 or 4,
            option = { additional_arguments = '--max-depth 8' },
            group_index = 1,
          },
          { name = 'emoji', priority = 3, group_index = 1 },
          {
            name = 'natdat',
            priority = 3,
            keyword_length = 3,
            group_index = 1,
          },
          {
            name = 'spell',
            max_item_count = 10,
            group_index = 2,
          },
          { name = 'norg', group_index = 2 },
          { name = 'render-markdown', group_index = 2 },
          { name = 'nerdfonts', group_index = 3 },
          { name = 'dotenv', group_index = 4 },
          { name = 'ecolog', group_index = 1 },
          { name = 'lazydev', group_index = 0 },
        },
      })

      if opts.snippet == nil then
        opts.snippet = {
          expand = function(args) vim.snippet.expand(args.body) end,
        }
      end
      return opts
    end,
    config = function(_, opts)
      local cmp = require('cmp')

      cmp.setup(opts)

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          sources = cmp.config.sources(
            { { name = 'nvim_lsp_document_symbol' } },
            { { name = 'buffer' } },
            { { name = 'buffer-lines' } }
          ),
        },
      })

      cmp.setup.cmdline(':', {
        sources = cmp.config.sources({
          { name = 'cmdline', keyword_pattern = [=[[^[:blank:]\!]*]=] },
          { name = 'path' },
          -- { name = 'cmdline_history', priority = 10, max_item_count = 5 },
        }),
      })

      cmp.setup.filetype({ 'dap-repl', 'dapui_watches' }, {
        sources = { { name = 'dap' } },
      })

      require('cmp').setup.filetype({ 'c', 'cpp' }, {
        sources = {
          { name = 'buffer-lines' },
        },
      })

      vim.api.nvim_create_user_command(
        'CmpInfo',
        function() cmp.status() end,
        {}
      )
    end,
    dependencies = {
      -- 'razak17/lab.nvim',
      'razak17/lspkind.nvim',
      -- 'dmitmel/cmp-cmdline-history',
      -- 'hrsh7th/cmp-path',
      'https://codeberg.org/FelipeLema/cmp-async-path',
      'hrsh7th/cmp-buffer',
      'lukas-reineke/cmp-rg',
      { 'hrsh7th/cmp-emoji', cond = not minimal },
      { 'fazibear/cmp-nerdfonts', cond = not minimal },
      { 'SergioRibera/cmp-dotenv', cond = not minimal and false },
      { 'ryo33/nvim-cmp-rust', ft = { 'rust' } },
      { 'Gelio/cmp-natdat', opts = {} },
      { 'hrsh7th/cmp-nvim-lsp', cond = ar.lsp.enable },
      { 'hrsh7th/cmp-cmdline', config = function() vim.o.wildmode = '' end },
      { 'hrsh7th/cmp-nvim-lsp-document-symbol', cond = ar.lsp.enable },
      {
        'uga-rosa/cmp-dictionary',
        cond = not minimal and ar.plugins.overrides.dict.enable,
        config = function()
          local en_dict =
            join_paths(fn.stdpath('data'), 'site', 'spell', 'en.dict')
          require('cmp_dictionary').setup({ paths = { en_dict } })
        end,
      },
    },
  },
  {
    'f3fora/cmp-spell',
    cond = ar.completion.enable and not minimal and is_cmp,
    ft = { 'gitcommit', 'NeogitCommitMessage', 'markdown', 'norg', 'org' },
  },
  {
    'rcarriga/cmp-dap',
    cond = ar.completion.enable and not minimal and is_cmp,
    ft = { 'dap-repl', 'dapui_watches' },
  },
  {
    'amarakon/nvim-cmp-buffer-lines',
    cond = ar.completion.enable and not minimal and is_cmp,
    ft = { 'c', 'cpp' },
  },
}
