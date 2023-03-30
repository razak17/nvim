local ui, fn, api, fmt = rvim.ui, vim.fn, vim.api, string.format
local border = ui.current.border
local lsp_hls = ui.lsp.highlights
local ellipsis = ui.icons.ui.ellipsis

return {
  {
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter' },
    config = function()
      local function get_color(r, g, b) return ((r * 0.299 + g * 0.587 + b * 0.114) > 186) and '#000000' or '#ffffff' end

      local function is_tailwind_root()
        return not vim.tbl_isempty(vim.fs.find({ 'tailwind.config.js', 'tailwind.config.cjs' }, {
          path = vim.fn.expand('%:p'),
          upward = true,
        }))
      end

      local function format_icon(icon)
        if is_tailwind_root() then return fmt(' %s  ', icon) end
        return fmt('%s ', icon)
      end

      local cmp = require('cmp')

      local luasnip = require('luasnip')

      local kind_hls = rvim.fold(
        function(accum, value, key)
          accum[#accum + 1] = { ['CmpItemKind' .. key] = { fg = { from = value } } }
          return accum
        end,
        lsp_hls,
        {
          { CmpItemAbbr = { fg = { from = 'Search' } } },
          { CmpItemAbbrDeprecated = { strikethrough = true, inherit = 'Comment' } },
          { CmpItemAbbrMatchFuzzy = { fg = { from = 'Title' } } },
          { CmpItemMenu = { fg = { from = 'Comment', attr = 'fg' }, italic = true, bold = true } },
        }
      )

      rvim.highlight.plugin('Cmp', kind_hls)

      local cmp_window = {
        border = border,
        winhighlight = table.concat({
          'Normal:NormalFloat',
          'FloatBorder:FloatBorder',
          'CursorLine:Visual',
          completion = { border = border },
          documentation = { border = border },
          'Search:None',
        }, ','),
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
        experimental = { ghost_text = false },
        matching = { disallow_partial_fuzzy_matching = false },
        preselect = cmp.PreselectMode.None,
        window = {
          completion = cmp.config.window.bordered(cmp_window),
          documentation = cmp.config.window.bordered(cmp_window),
        },
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
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
          fields = { 'kind', 'abbr', 'menu' },
          format = function(entry, vim_item)
            local MAX = math.floor(vim.o.columns * 0.5)
            if #vim_item.abbr >= MAX then vim_item.abbr = vim_item.abbr:sub(1, MAX) .. ellipsis end

            local codicons = ui.codicons
            local lsp_icons = ui.current.lsp_icons

            if vim_item.kind ~= 'Color' then vim_item.kind = format_icon(lsp_icons[vim_item.kind]) end

            if entry.source.name == 'emoji' then vim_item.kind = format_icon(codicons.misc.smiley) end

            if entry.source.name == 'lab.quick_data' then vim_item.kind = format_icon(codicons.misc.robot) end

            if entry.source.name == 'dynamic' then vim_item.kind = format_icon(codicons.ui.calendar) end

            if entry.source.name == 'crates' then vim_item.kind = format_icon(ui.codicons.ui.package) end

            if vim_item.kind == 'Color' then
              if entry.completion_item.documentation then
                local _, _, r, g, b = string.find(entry.completion_item.documentation, '^rgb%((%d+), (%d+), (%d+)')
                if r then
                  local color = fmt('%s%s%s', fmt('%02x', r), fmt('%02x', g), fmt('%02x', b))
                  local group = fmt('CmpItemKind_%s', color)
                  if fn.hlID(group) < 1 then
                    api.nvim_set_hl(0, group, { fg = get_color(r, g, b), bg = fmt('#%s', color) })
                  end
                  vim_item.kind_hl_group = group
                end
              end
              vim_item.kind = format_icon(lsp_icons[vim_item.kind])
            end

            vim_item.menu = ({
              nvim_lsp = '(Lsp)',
              luasnip = '(Snip)',
              emoji = '(Emj)',
              path = '(Path)',
              buffer = '(Buf)',
              spell = '(Sp)',
              dictionary = '(Dict)',
              rg = '(Rg)',
              norg = '(norg)',
              cmdline = '(Cmd)',
              cmdline_history = '(Hist)',
              crates = '(Crt)',
              treesitter = '(TS)',
              ['buffer-lines'] = '(Bufl)',
              dynamic = '(Dyn)',
              ['lab.quick_data'] = '(Lab)',
            })[entry.source.name]
            return vim_item
          end,
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          {
            name = 'rg',
            max_item_count = 10,
            option = { additional_arguments = '--max-depth 8' },
          },
          -- { name = 'dictionary' },
          { name = 'crates' },
          { name = 'treesitter' },
          { name = 'lab.quick_data' },
          { name = 'dynamic' },
          { name = 'emoji' },
        }, {
          {
            name = 'buffer',
            options = {
              get_bufnrs = function() return vim.api.nvim_list_bufs() end,
            },
          },
          { name = 'spell' },
        }),
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
      'hrsh7th/cmp-nvim-lsp',
      'saadparwaiz1/cmp_luasnip',
      {
        'hrsh7th/cmp-cmdline',
        config = function()
          vim.o.wildmode = '' -- Shows a menu bar rvim opposed to an enormous list
        end,
      },
      'dmitmel/cmp-cmdline-history',
      'hrsh7th/cmp-nvim-lsp-document-symbol',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-emoji',
      'lukas-reineke/cmp-rg',
      { 'rcarriga/cmp-dap', ft = { 'dap-repl', 'dapui_watches' } },
      { 'amarakon/nvim-cmp-buffer-lines', ft = { 'c', 'cpp' } },
      {
        'f3fora/cmp-spell',
        ft = { 'gitcommit', 'NeogitCommitMessage', 'markdown', 'norg', 'org' },
      },
      {
        'uga-rosa/cmp-dictionary',
        enabled = false,
        config = function()
          -- NOTE: run :CmpDictionaryUpdate to update dictionary
          require('cmp_dictionary').setup({
            async = false,
            dic = {
              -- Refer to install script
              ['*'] = join_paths(vim.call('stdpath', 'data'), 'site', 'spell', 'dictionary.txt'),
            },
          })
        end,
      },
      {
        'uga-rosa/cmp-dynamic',
        config = function()
          local Date = require('cmp_dynamic.utils.date')
          require('cmp_dynamic').register({
            {
              label = 'today',
              insertText = 1,
              cb = { function() return os.date('%Y/%m/%d') end },
            },
            {
              label = 'tomorrow',
              insertText = 1,
              cb = { function() return Date.new():add_date(1):format('%Y/%m/%d') end },
            },
            {
              label = 'next Week',
              insertText = 1,
              cb = {
                function() return Date.new():add_date(7):format('%Y/%m/%d') end,
              },
              resolve = true, -- default: false
            },
            {
              label = 'next Monday',
              insertText = 1,
              cb = { function() return Date.new():add_date(7):day(1):format('%Y/%m/%d') end },
              resolve = true, -- default: false
            },
          })
        end,
      },
    },
  },
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
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
