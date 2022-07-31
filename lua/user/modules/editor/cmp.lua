return function()
  if not rvim.plugin_installed('nvim-cmp') then return end

  local status_cmp_ok, cmp = rvim.safe_require('cmp')
  if not status_cmp_ok then return end

  local fn, api = vim.fn, vim.api

  local t = rvim.replace_termcodes
  local border = rvim.style.border.current
  local lsp_hls = rvim.lsp.kind_highlights
  local util = require('user.utils.highlights')
  local ellipsis = rvim.style.icons.misc.ellipsis

  local kind_hls = rvim.fold(
    function(accum, value, key)
      accum['CmpItemKind' .. key] = { foreground = { from = value } }
      return accum
    end,
    lsp_hls,
    {
      CmpItemAbbr = { foreground = 'fg', background = 'NONE', italic = false, bold = false },
      CmpItemAbbrDeprecated = { strikethrough = true, inherit = 'Comment' },
      CmpItemAbbrMatchFuzzy = { italic = true, foreground = { from = 'Keyword' } },
      -- Make the source information less prominent
      CmpItemMenu = {
        fg = { from = 'Pmenu', attr = 'bg', alter = 30 },
        italic = true,
        bold = false,
      },
    }
  )

  util.plugin('Cmp', kind_hls)

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
    local ok, luasnip = rvim.safe_require('luasnip', { silent = true })
    if cmp.visible() then
      cmp.select_next_item()
      return
    end
    if ok and luasnip.expand_or_locally_jumpable() then
      luasnip.expand_or_jump()
      return
    end
    fallback()
  end

  local function shift_tab(fallback)
    local ok, luasnip = rvim.safe_require('luasnip', { silent = true })
    if cmp.visible() then
      cmp.select_prev_item()
      return
    end
    if ok and luasnip.jumpable(-1) then
      luasnip.jump(-1)
      return
    end
    fallback()
  end

  rvim.cmp = {
    setup = {
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
        },
        format = function(entry, vim_item)
          local MAX = math.floor(vim.o.columns * 0.5)
          local codicons = rvim.style.codicons
          if #vim_item.abbr >= MAX then vim_item.abbr = vim_item.abbr:sub(1, MAX) .. ellipsis end
          vim_item.kind = codicons.kind[vim_item.kind]
          if entry.source.name == 'emoji' then vim_item.kind = codicons.misc.smiley end
          vim_item.menu = rvim.cmp.setup.formatting.source_names[entry.source.name]
          return vim_item
        end,
      },
      sources = {
        { name = 'luasnip' },
        { name = 'nvim_lsp' },
        { name = 'path' },
        {
          name = 'buffer',
          keyword_length = 2,
          options = {
            get_bufnrs = function()
              local bufs = {}
              for _, win in ipairs(api.nvim_list_wins()) do
                bufs[api.nvim_win_get_buf(win)] = true
              end
              return vim.tbl_keys(bufs)
            end,
          },
        },
        {
          name = 'dictionary',
          keyword_length = 3,
        },
        { name = 'spell' },
        { name = 'git' },
        { name = 'calc' },
        { name = 'emoji' },
        { name = 'nvim_lsp_document_symbol' },
        { name = 'cmdline_history', priority = 10, max_item_count = 5 },
      },
    },
  }

  require('cmp').setup(rvim.cmp.setup)

  local search_sources = {
    sources = cmp.config.sources({
      { name = 'nvim_lsp_document_symbol' },
    }, {
      { name = 'buffer' },
    }),
  }

  cmp.setup.cmdline('/', search_sources)
  cmp.setup.cmdline('?', search_sources)
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'cmdline', keyword_pattern = [=[[^[:blank:]\!]*]=] },
      { name = 'path' },
      -- { name = 'cmdline_history' },
    }),
  })

  -- FIXME: this should not be required if we were using a prompt buffer in telescope i.e. prompt prefix
  -- Deactivate cmp in telescope prompt buffer
  rvim.augroup('CmpConfig', {
    {
      event = { 'FileType' },
      pattern = { 'TelescopePrompt' },
      command = function() cmp.setup.buffer({ completion = { autocomplete = false } }) end,
    },
  })
end
