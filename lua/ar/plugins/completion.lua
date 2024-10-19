local api, fn, fmt, k = vim.api, vim.fn, string.format, vim.keycode
local ui, highlight = ar.ui, ar.highlight
local border, lsp_hls, ellipsis =
  ui.current.border, ui.lsp.highlights, ui.icons.misc.ellipsis
local minimal = ar.plugins.minimal
local codicons = ui.codicons

ar.completion.config = {
  format = {
    ['emoji'] = { icon = codicons.misc.smiley, hl = 'CmpItemKindEmoji' },
    ['lab.quick_data'] = { icon = ui.icons.misc.beaker, hl = 'CmpItemKindLab' },
    ['natdat'] = { icon = codicons.misc.calendar, hl = 'CmpItemKindDynamic' },
    ['crates'] = { icon = codicons.misc.package, hl = 'CmpItemKindDynamic' },
    ['copilot'] = { icon = codicons.misc.octoface, hl = 'CmpItemKindCopilot' },
    ['nerdfonts'] = { icon = '', hl = 'CmpItemKindNerdFont' },
    ['nvim_px_to_rem'] = { icon = '', hl = 'CmpItemKindNerdFont' },
    ['Color'] = { icon = '' },
  },
  menu = {
    Color = '[COLOR]',
    copilot = '[CPL]',
    codeium = '[CM]',
    nvim_lsp = '[LSP]',
    luasnip = '[SNIP]',
    snippets = '[SNIP]',
    emoji = '[EMOJI]',
    path = '[PATH]',
    neorg = '[NEORG]',
    buffer = '[BUF]',
    spell = '[SPELL]',
    dictionary = '[DICT]',
    rg = '[RG]',
    norg = '[NORG]',
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
  },
}

return {
  {
    -- 'hrsh7th/nvim-cmp',
    'iguanacucumber/magazine.nvim',
    name = 'nvim-cmp',
    cond = ar.completion.enable,
    event = 'InsertEnter',
    opts = function()
      local snippet = vim.snippet
      local cmp = require('cmp')
      local types = require('cmp.types')
      local luasnip_avail, luasnip = pcall(require, 'luasnip')
      local MiniIcons = require('mini.icons')
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
            { CmpItemKindCodeium = { link = 'CmpItemKindCopilot' } },
          }),
        },
      })

      -- https://github.com/simifalaye/dotfiles/blob/main/roles/neovim/dots/.config/nvim/lua/plugins/cmp.lua#L35
      local function has_words_before()
        local line, col = (unpack or table.unpack)(api.nvim_win_get_cursor(0))
        return col ~= 0
          and api
              .nvim_buf_get_lines(0, line - 1, line, true)[1]
              :sub(col, col)
              :match('%s')
            == nil
      end

      local function tab(fallback)
        if snippet.active({ direction = 1 }) then return snippet.jump(1) end
        if has_words_before() and not cmp.visible() then
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
        if has_words_before() and not cmp.visible() then
          return cmp.complete()
        end
        if not cmp.visible() then return fallback() end
        if cmp.visible() then return cmp.select_prev_item() end
        if luasnip_avail and luasnip.jumpable(-1) then
          return luasnip.jump(-1)
        end
      end

      local function copilot()
        local suggestion = require('copilot.suggestion')
        if suggestion.is_visible() then return suggestion.accept() end
        api.nvim_feedkeys(k('<Tab>'), 'n', false)
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

      return {
        performance = { debounce = 0, throttle = 0 },
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
        snippet = {
          expand = function(args)
            if luasnip_avail then
              luasnip.lsp_expand(args.body)
            else
              vim.snippet.expand(args.body)
            end
          end,
        },
        mapping = {
          ['<C-]>'] = cmp.mapping(copilot),
          ['<C-k>'] = cmp.mapping.select_prev_item(),
          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
          ['<Tab>'] = cmp.mapping(tab, { 'i', 's', 'c' }),
          ['<S-Tab>'] = cmp.mapping(shift_tab, { 'i', 's', 'c' }),
          ['<C-q>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ['<C-u>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = false }), -- If nothing is selected don't complete
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

            local custom_sources = {
              'emoji',
              'lab.quick_data',
              'natdat',
              'crates',
              'copilot',
              'nerdfonts',
              'nvim_px_to_rem',
            }

            if
              not ar.find_string(custom_sources, entry.source.name)
              and item.kind ~= 'Color'
            then
              if ar.completion.icons == 'mini.icons' then
                local icon, hl = MiniIcons.get('lsp', item.kind)
                item.kind = icon
                item.kind_hl_group = hl
              elseif ar.completion.icons == 'lspkind' then
                item.kind = format_icon(symbols[item.kind])
              end
            end

            local format = ar.completion.config.format
            local config = format[entry.source.name]

            if config then
              item.kind = format_icon(config.icon)
              item.kind_hl_group = config.hl
            end

            local function get_color(color_item, color_entry)
              local entry_item = color_entry:get_completion_item()
              local color = entry_item.documentation
              if
                color
                and type(color) == 'string'
                and color:match('^#%x%x%x%x%x%x$')
              then
                local hl = 'hex-' .. color:sub(2)
                if #api.nvim_get_hl(0, { name = hl }) == 0 then
                  api.nvim_set_hl(0, hl, { fg = color })
                end
                color_item.kind = format['Color'].icon
                color_item.kind_hl_group = hl
              else
                color_item.kind = format_icon(symbols[item.kind])
              end
              return color_item
            end

            if item.kind == 'Color' then
              vim.o.pumblend = 3
              item.menu = '[COLOR]'
              if item.kind == 'Color' then item = get_color(item, entry) end
            end
            return item
          end,
        },
        sources = {
          { name = 'copilot', priority = 11, group_index = 1 },
          { name = 'codeium', priority = 11, group_index = 1 },
          { name = 'nvim_px_to_rem', priority = 11, group_index = 1 },
          { name = 'nvim_lsp', priority = 10, group_index = 1 },
          { name = 'luasnip', priority = 9, group_index = 1 },
          { name = 'snippets', priority = 9, group_index = 1 },
          {
            name = 'lab.quick_data',
            priority = 6,
            max_item_count = 10,
            group_index = 1,
          },
          {
            name = 'buffer',
            priority = 6,
            options = {
              get_bufnrs = function() return api.nvim_list_bufs() end,
            },
            group_index = 1,
          },
          { name = 'path', priority = 5, group_index = 1 },
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
          { name = 'nerdfonts', group_index = 3 },
          { name = 'dotenv', group_index = 4 },
          { name = 'lazydev', group_index = 0 },
        },
      }
    end,
    config = function(_, opts)
      local cmp = require('cmp')

      cmp.setup(opts)

      cmp.event:on(
        'menu_opened',
        function() vim.b.copilot_suggestion_hidden = true end
      )
      cmp.event:on(
        'menu_closed',
        function() vim.b.copilot_suggestion_hidden = false end
      )

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
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'lukas-reineke/cmp-rg',
      'saadparwaiz1/cmp_luasnip',
      { 'hrsh7th/cmp-emoji', cond = not minimal },
      { 'fazibear/cmp-nerdfonts', cond = not minimal },
      { 'SergioRibera/cmp-dotenv', cond = not minimal },
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
      {
        'zbirenbaum/copilot-cmp',
        cond = ar.ai.enable and not minimal,
        opts = {},
        config = function(_, opts)
          require('copilot_cmp').setup(opts)

          ar.ftplugin_conf({
            cmp = function(cmp)
              cmp.setup.filetype('norg', {
                sorting = {
                  require('copilot_cmp.comparators').prioritize,
                },
              })
            end,
          })
        end,
      },
      {
        'Exafunction/codeium.nvim',
        enabled = false,
        cond = ar.ai.enable and not minimal and false,
        opts = {},
      },
    },
  },
  {
    'f3fora/cmp-spell',
    cond = ar.completion.enable and not minimal,
    ft = { 'gitcommit', 'NeogitCommitMessage', 'markdown', 'norg', 'org' },
  },
  {
    'rcarriga/cmp-dap',
    cond = ar.completion.enable and not minimal,
    ft = { 'dap-repl', 'dapui_watches' },
  },
  {
    'amarakon/nvim-cmp-buffer-lines',
    cond = ar.completion.enable,
    ft = { 'c', 'cpp' },
  },
  {
    'jsongerber/nvim-px-to-rem',
    cond = ar.completion.enable and not minimal,
    ft = { 'css', 'scss' },
    opts = { show_virtual_text = true },
  },
  {
    'razak17/wilder.nvim',
    enabled = false,
    cond = not minimal and false,
    keys = { '/', '?', ':' },
    build = ':UpdateRemotePlugins',
    event = { 'CmdlineEnter', 'CmdlineLeave' },
    config = function()
      -- wilder
      local wilder = require('wilder')
      wilder.setup({ modes = { ':', '/', '?' } })
      wilder.set_option('pipeline', {
        wilder.branch(
          wilder.python_file_finder_pipeline({
            file_command = function(_, arg)
              if string.find(arg, '.') ~= nil then
                return { 'fd', '-tf', '-H' }
              else
                return { 'fd', '-tf' }
              end
            end,
            dir_command = { 'fd', '-td' },
            filters = { 'fuzzy_filter', 'difflib_sorter' },
          }),
          wilder.cmdline_pipeline(),
          wilder.python_search_pipeline()
        ),
      })

      highlight.plugin('wilder', {
        theme = {
          ['onedark'] = {
            { WilderMenu = { fg = { from = 'WildMenu' } } },
            { WilderAccent = { link = 'Directory' } },
          },
        },
      })

      wilder.set_option(
        'renderer',
        wilder.popupmenu_renderer({
          highlighter = wilder.basic_highlighter(),
          left = { ' ', wilder.popupmenu_devicons() },
          right = { ' ', wilder.popupmenu_scrollbar({ thumb_char = ' ' }) },
          highlights = {
            default = 'WilderMenu',
            -- accent = 'Variable',
            selected_accent = 'PmenuSel',
            accent = wilder.make_hl(
              'WilderAccent',
              'Pmenu',
              { { a = 1 }, { a = 1 }, { foreground = '#f4468f' } }
            ),
          },
        })
      )
    end,
  }, -- : autocomplete
}
