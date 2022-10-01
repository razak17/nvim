return function()
  local cmp = require('cmp')
  local h = require('user.utils.highlights')

  local fn, api = vim.fn, vim.api
  local t = rvim.replace_termcodes
  local border = rvim.style.border.current
  local lsp_hls = rvim.lsp.kind_highlights
  local ellipsis = rvim.style.icons.misc.ellipsis
  local luasnip = require('luasnip')

  local kind_hls = rvim.fold(
    function(accum, value, key)
      accum[#accum + 1] = { ['CmpItemKind' .. key] = { foreground = { from = value } } }
      return accum
    end,
    lsp_hls,
    {
      { CmpItemAbbr = { foreground = 'fg', background = 'NONE', italic = false, bold = false } },
      { CmpItemAbbrDeprecated = { strikethrough = true, inherit = 'Comment' } },
      { CmpItemAbbrMatchFuzzy = { italic = true, foreground = { from = 'Keyword' } } },
      -- Make the source information less prominent
      {
        CmpItemMenu = {
          fg = { from = 'LineNr', attr = 'fg' },
          italic = true,
          bold = false,
        },
      },
    }
  )

  h.plugin('Cmp', kind_hls)

  local cmp_window = {
    border = border,
    winhighlight = table.concat({
      'Normal:NormalFloat',
      'FloatBorder:FloatBorder',
      'CursorLine:Visual',
      completion = {
        -- TODO: consider 'shadow', and tweak the winhighlight
        border = border,
      },
      documentation = {
        border = border,
      },
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
    preselect = cmp.PreselectMode.None,
    window = {
      completion = cmp.config.window.bordered(cmp_window),
      documentation = cmp.config.window.bordered(cmp_window),
    },
    snippet = {
      expand = function(args) require('luasnip').lsp_expand(args.body) end,
    },
    mapping = {
      ['<c-h>'] = cmp.mapping(
        function() api.nvim_feedkeys(fn['copilot#Accept'](t('<Tab>')), 'n', true) end
      ),
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
      fields = { 'kind', 'abbr', 'menu' },
      source_names = {
        luasnip = '(SN)',
        nvim_lsp = '(LSP)',
        path = '(Path)',
        buffer = '(Buf)',
        dictionary = '(Dict)',
        spell = '(SP)',
        cmdline = '(Cmd)',
        git = '(Git)',
        calc = '(Calc)',
        emoji = '(E)',
        cmdline_history = '(Hist)',
        rg = '(Rg)',
      },
      format = function(entry, vim_item)
        local MAX = math.floor(vim.o.columns * 0.5)
        local codicons = rvim.style.codicons
        if #vim_item.abbr >= MAX then vim_item.abbr = vim_item.abbr:sub(1, MAX) .. ellipsis end
        vim_item.kind = codicons.kind[vim_item.kind]
        vim_item.menu = ({
          nvim_lsp = '(LSP)',
          luasnip = '(SN)',
          path = '(Path)',
          buffer = '(Buf)',
          dictionary = '(Dict)',
          spell = '(SP)',
          cmdline = '(Cmd)',
          git = '(Git)',
          calc = '(Calc)',
          cmdline_history = '(Hist)',
          rg = '(Rg)',
          crates = '(Crt)',
        })[entry.source.name]
        return vim_item
      end,
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp', max_item_count = 5 },
      { name = 'luasnip', max_item_count = 3 },
      { name = 'path' },
      {
        name = 'rg',
        keyword_length = 3,
        max_item_count = 3,
        option = { additional_arguments = '--max-depth 8' },
      },
      {
        name = 'dictionary',
        keyword_length = 3,
        max_item_count = 3,
      },
      { name = 'crates', gropu_index = 1 },
    }, {
      {
        name = 'buffer',
        keyword_length = 2,
        options = {
          get_bufnrs = function() return vim.api.nvim_list_bufs() end,
        },
      },
      { name = 'spell' },
    }),
  })

  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      sources = cmp.config.sources(
        { { name = 'nvim_lsp_document_symbol' } },
        { { name = 'buffer' } }
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
  require('cmp').setup.filetype({ 'dap-repl', 'dapui_watches' }, {
    sources = { { name = 'dap' } },
  })
end
