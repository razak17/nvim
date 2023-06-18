local fn, api, fmt = vim.fn, vim.api, string.format
local ui, fold = rvim.ui, rvim.fold
local border, lsp_hls, ellipsis = ui.current.border, ui.lsp.highlights, ui.icons.misc.ellipsis

return {
  { 'f3fora/cmp-spell', ft = { 'gitcommit', 'NeogitCommitMessage', 'markdown', 'norg', 'org' } },
  { 'rcarriga/cmp-dap', ft = { 'dap-repl', 'dapui_watches' } },
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local symbols = require('lspkind').symbol_map
      local codicons = ui.codicons
      local MIN_MENU_WIDTH, MAX_MENU_WIDTH = 25, math.min(50, math.floor(vim.o.columns * 0.5))

      local hl_defs = fold(
        function(accum, value, key)
          table.insert(accum, { [fmt('CmpItemKind%s', key)] = { fg = { from = value } } })
          return accum
        end,
        lsp_hls,
        {
          { CmpItemAbbr = { fg = { from = 'MsgSeparator' } } },
          { CmpItemAbbrDeprecated = { strikethrough = true, inherit = 'Comment' } },
          { CmpItemAbbrMatch = { fg = { from = 'Search' } } },
          { CmpItemAbbrMatchFuzzy = { fg = { from = 'Search' } } },
          { CmpItemMenu = { fg = { from = 'Comment', attr = 'fg' }, italic = true, bold = true } },
        }
      )

      rvim.highlight.plugin('Cmp', hl_defs)

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

      cmp.setup({
        preselect = cmp.PreselectMode.None,
        window = {
          completion = cmp.config.window.bordered(window_opts),
          documentation = cmp.config.window.bordered(window_opts),
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
          ['<C-k>'] = cmp.mapping.select_prev_item(),
          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
          ['<Tab>'] = cmp.mapping(tab, { 'i', 's', 'c' }),
          ['<S-Tab>'] = cmp.mapping(shift_tab, { 'i', 's', 'c' }),
          ['<C-q>'] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
          ['<C-space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = false }), -- If nothing is selected don't complete
        },
        formatting = {
          deprecated = true,
          fields = { 'abbr', 'kind', 'menu' },
          format = function(entry, vim_item)
            local label, length = vim_item.abbr, api.nvim_strwidth(vim_item.abbr)
            local function format_icon(icon) return fmt('%s ', icon) end

            if length < MIN_MENU_WIDTH then vim_item.abbr = label .. string.rep(' ', MIN_MENU_WIDTH - length) end
            if #vim_item.abbr >= MAX_MENU_WIDTH then
              vim_item.abbr = vim_item.abbr:sub(1, MAX_MENU_WIDTH) .. ellipsis
            end

            local custom_sources = { 'emoji', 'lab.quick_data', 'dynamic', 'crates' }

            if not rvim.find_string(custom_sources, entry.source.name) and vim_item.kind ~= 'Color' then
              vim_item.kind = format_icon(symbols[vim_item.kind])
            end
            if entry.source.name == 'emoji' then vim_item.kind = format_icon(codicons.misc.smiley) end
            if entry.source.name == 'lab.quick_data' then vim_item.kind = format_icon(codicons.misc.robot) end
            if entry.source.name == 'dynamic' then vim_item.kind = format_icon(codicons.misc.calendar) end
            if entry.source.name == 'crates' then vim_item.kind = format_icon(ui.codicons.misc.package) end

            if vim_item.kind == 'Color' then
              if entry.completion_item.documentation then
                local _, _, r, g, b = string.find(entry.completion_item.documentation, '^rgb%((%d+), (%d+), (%d+)')
                if r then
                  local color = fmt('%s%s%s', fmt('%02x', r), fmt('%02x', g), fmt('%02x', b))
                  local group = fmt('CmpItemKind_%s', color)
                  if fn.hlID(group) < 1 then api.nvim_set_hl(0, group, { bg = fmt('#%s', color) }) end
                  vim_item.kind_hl_group = group
                end
              end
              vim_item.kind = string.rep(' ', 2)
            end

            vim_item.menu = ({
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
              dynamic = '[DYN]',
              ['lab.quick_data'] = '[LAB]',
            })[entry.source.name]
            return vim_item
          end,
        },
        sources = {
          { name = 'nvim_lsp', priority = 10, group_index = 1 },
          { name = 'luasnip', priority = 9, group_index = 1 },
          {
            name = 'rg',
            priority = 8,
            keyword_length = 3,
            max_item_count = 10,
            option = { additional_arguments = '--max-depth 8' },
            group_index = 1,
          },
          {
            name = 'lab.quick_data',
            priority = 6,
            max_item_count = 10,
            group_index = 1,
          },
          { name = 'path', priority = 4, group_index = 1 },
          { name = 'emoji', priority = 3, group_index = 1 },
          { name = 'dynamic', priority = 3, group_index = 1 },
          {
            name = 'buffer',
            priority = 3,
            options = { get_bufnrs = function() return vim.api.nvim_list_bufs() end },
            group_index = 2,
          },
          {
            name = 'spell',
            priority = 3,
            max_item_count = 10,
            group_index = 2,
          },
          { name = 'norg', priority = 3, group_index = 2 },
        },
      })

      cmp.event:on('menu_opened', function() vim.b.copilot_suggestion_hidden = true end)
      cmp.event:on('menu_closed', function() vim.b.copilot_suggestion_hidden = false end)

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
    end,
    dependencies = {
      'dmitmel/cmp-cmdline-history',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-emoji',
      'lukas-reineke/cmp-rg',
      { 'hrsh7th/cmp-nvim-lsp', enabled = rvim.lsp.enable },
      { 'hrsh7th/cmp-cmdline', config = function() vim.o.wildmode = '' end },
      { 'hrsh7th/cmp-nvim-lsp-document-symbol', enabled = rvim.lsp.enable },
      'saadparwaiz1/cmp_luasnip',
      { 'amarakon/nvim-cmp-buffer-lines', ft = { 'c', 'cpp' } },
      {
        'uga-rosa/cmp-dictionary',
        config = function()
          local en_dict = join_paths(vim.fn.stdpath('data'), 'site', 'spell', 'en.dict')
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
        'uga-rosa/cmp-dynamic',
        config = function()
          local Date = require('cmp_dynamic.utils.date')
          require('cmp_dynamic').register({
            { label = 'today', insertText = os.date('%Y/%m/%d') },
            { label = 'tomorrow', insertText = Date.new():add_date(1):format('%Y/%m/%d') },
            { label = 'next Week', insertText = Date.new():add_date(7):format('%Y/%m/%d'), resolve = true },
            { label = 'next Monday', insertText = Date.new():add_date(7):day(1):format('%Y/%m/%d'), resolve = true },
          })
        end,
      },
    },
  },
  {
    'zbirenbaum/copilot.lua',
    enabled = rvim.ai.enable and not rvim.plugins.minimal,
    event = 'InsertEnter',
    keys = {
      { '<leader>ap', '<Cmd>Copilot panel<CR>', desc = 'copilot: toggle panel' },
      { '<leader>at', '<Cmd>Copilot toggle<CR>', desc = 'copilot: toggle' },
    },
    opts = {
      suggestion = {
        auto_trigger = true,
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
}
