local api, fmt, k = vim.api, string.format, vim.keycode
local ui = rvim.ui
local border, lsp_hls, ellipsis =
  ui.current.border, ui.lsp.highlights, ui.icons.misc.ellipsis

return {
  {
    'f3fora/cmp-spell',
    ft = { 'gitcommit', 'NeogitCommitMessage', 'markdown', 'norg', 'org' },
  },
  { 'rcarriga/cmp-dap', ft = { 'dap-repl', 'dapui_watches' } },
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local symbols = require('lspkind').symbol_map
      local codicons = ui.codicons
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

      rvim.highlight.plugin(
        'Cmp',
        vim.tbl_extend('force', hl_defs, {
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
          { CmpItemKindLab = { fg = { from = 'DiagnosticWarn' } } },
          { CmpItemKindDynamic = { fg = { from = 'Directory' } } },
        })
      )

      local window_opts = {
        border = border,
        winhighlight = 'FloatBorder:FloatBorder',
      }

      local function tab(fallback)
        if cmp.visible() then
          cmp.select_next_item()
          return
        end
        if luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
          return
        end
        fallback()
      end

      local function shift_tab(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
          return
        end
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
          return
        end
        fallback()
      end

      local function copilot()
        local suggestion = require('copilot.suggestion')
        if suggestion.is_visible() then return suggestion.accept() end
        api.nvim_feedkeys(k('<Tab>'), 'n', false)
      end

      cmp.setup({
        preselect = cmp.PreselectMode.None,
        window = {
          completion = cmp.config.window.bordered(window_opts),
          documentation = cmp.config.window.bordered(window_opts),
        },
        sorting = {
          comparators = {
            rvim.is_available('copilot-cmp') and require(
              'copilot_cmp.comparators'
            ).prioritize or nil,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.kind,
            cmp.config.compare.order,
            cmp.config.compare.length,
            cmp.config.compare.sort_text,
          },
        },
        matching = {
          disallow_fuzzy_matching = false,
          disallow_fullfuzzy_matching = true,
          disallow_partial_fuzzy_matching = true,
          disallow_partial_matching = true,
          disallow_prefix_unmatching = false,
        },
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
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
          ['<C-space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = false }), -- If nothing is selected don't complete
        },
        formatting = {
          deprecated = true,
          fields = { 'abbr', 'kind', 'menu' },
          format = function(entry, item)
            item.menu = ({
              copilot = '[CPL]',
              nvim_lsp = '[LSP]',
              luasnip = '[SNIP]',
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
            })[entry.source.name]

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
              not rvim.find_string(custom_sources, entry.source.name)
              and item.kind ~= 'Color'
            then
              item.kind = format_icon(symbols[item.kind])
            end
            if entry.source.name == 'emoji' then
              item.kind = format_icon(codicons.misc.smiley)
            end
            if entry.source.name == 'lab.quick_data' then
              item.kind = format_icon(codicons.misc.robot)
              item.kind_hl_group = 'CmpItemKindLab'
            end
            if entry.source.name == 'natdat' then
              item.kind = format_icon(codicons.misc.calendar)
              item.kind_hl_group = 'CmpItemKindDynamic'
            end
            if entry.source.name == 'crates' then
              item.kind = format_icon(ui.codicons.misc.package)
            end
            if entry.source.name == 'copilot' then
              item.kind = format_icon(ui.codicons.misc.octoface)
            end
            --
            if entry.source.name == 'nerdfonts' then
              item.kind = format_icon('')
              item.kind_hl_group = 'CmpItemKindNerdFont'
            end
            if entry.source.name == 'nvim_px_to_rem' then
              item.kind = format_icon('')
              item.kind_hl_group = 'CmpItemKindNerdFont'
            end

            if item.kind == 'Color' then
              vim.o.pumblend = 3
              item = require('cmp-tailwind-colors').format(entry, item)
              item.menu = '[COLOR]'
              if item.kind == 'Color' then
                item.kind = format_icon(symbols[item.kind])
              end
            end
            return item
          end,
        },
        sources = {
          { name = 'copilot', priority = 11, group_index = 1 },
          { name = 'nvim_px_to_rem', priority = 11, group_index = 1 },
          { name = 'nvim_lsp', priority = 10, group_index = 1 },
          { name = 'luasnip', priority = 9, group_index = 1 },
          {
            name = 'lab.quick_data',
            priority = 6,
            max_item_count = 10,
            group_index = 1,
          },
          { name = 'path', priority = 4, group_index = 1 },
          { name = 'emoji', priority = 3, group_index = 1 },
          {
            name = 'natdat',
            priority = 3,
            keyword_length = 3,
            group_index = 1,
          },
          {
            name = 'rg',
            priority = 3,
            keyword_length = 4,
            option = { additional_arguments = '--max-depth 8' },
            group_index = 1,
          },
          {
            name = 'buffer',
            priority = 3,
            keyword_length = 4,
            options = {
              get_bufnrs = function() return vim.api.nvim_list_bufs() end,
            },
            group_index = 1,
          },
          {
            name = 'spell',
            priority = 3,
            max_item_count = 10,
            group_index = 2,
          },
          { name = 'nerdfonts', priority = 3, group_index = 2 },
          { name = 'norg', priority = 3, group_index = 2 },
        },
      })

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
          { name = 'cmdline_history', priority = 10, max_item_count = 5 },
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
      'razak17/lab.nvim',
      'razak17/lspkind.nvim',
      'dmitmel/cmp-cmdline-history',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-emoji',
      'lukas-reineke/cmp-rg',
      'fazibear/cmp-nerdfonts',
      'saadparwaiz1/cmp_luasnip',
      { 'Gelio/cmp-natdat', opts = {} },
      { 'hrsh7th/cmp-nvim-lsp', cond = rvim.lsp.enable },
      { 'hrsh7th/cmp-cmdline', config = function() vim.o.wildmode = '' end },
      { 'hrsh7th/cmp-nvim-lsp-document-symbol', cond = rvim.lsp.enable },
      {
        'uga-rosa/cmp-dictionary',
        cond = not rvim.plugins.minimal,
        config = function()
          local en_dict =
            join_paths(vim.fn.stdpath('data'), 'site', 'spell', 'en.dict')
          require('cmp_dictionary').switcher({
            filetype = {
              markdown = en_dict,
              NeogitCommitMessage = en_dict,
              norg = en_dict,
              slide = en_dict,
            },
          })
        end,
      },
      {
        'zbirenbaum/copilot-cmp',
        cond = rvim.ai.enable and not rvim.plugins.minimal,
        opts = {},
        dependencies = 'copilot.lua',
      },
    },
  },
  {
    'zbirenbaum/copilot.lua',
    cond = rvim.ai.enable and not rvim.plugins.minimal,
    event = 'InsertEnter',
    keys = {
      {
        '<leader>ap',
        '<Cmd>Copilot panel<CR>',
        desc = 'copilot: toggle panel',
      },
      { '<leader>at', '<Cmd>Copilot toggle<CR>', desc = 'copilot: toggle' },
    },
    opts = {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = not rvim.plugins.overrides.copilot_cmp.enable,
        keymap = {
          accept_word = '<M-w>',
          accept_line = '<M-l>',
          accept = '<M-u>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-\\>',
        },
      },
      filetypes = {
        gitcommit = false,
        NeogitCommitMessage = false,
        DressingInput = false,
        TelescopePrompt = false,
        ['neo-tree-popup'] = false,
        ['dap-repl'] = false,
      },
      server_opts_overrides = {
        settings = {
          advanced = { inlineSuggestCount = 3 },
        },
      },
    },
  },
  { 'amarakon/nvim-cmp-buffer-lines', ft = { 'c', 'cpp' } },
  {
    'js-everts/cmp-tailwind-colors',
    ft = { 'css', 'html', 'vue', 'javascriptreact', 'typescriptreact' },
    opts = {},
  },
  {
    'jsongerber/nvim-px-to-rem',
    ft = { 'css', 'scss' },
    opts = { disable_keymaps = true },
  },
}
