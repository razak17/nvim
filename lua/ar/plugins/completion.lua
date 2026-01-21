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
local is_cmp = ar.config.completion.variant == 'cmp'

ar.completion.config = vim.tbl_extend('force', ar.completion.config or {}, {
  format = {
    Color = { icon = ui.icons.misc.block_medium },
  },
  menu = {
    Color = '[COLOR]',
  },
})

return {
  {
    'hrsh7th/nvim-cmp',
    cond = function()
      local condition = ar.completion.enable and is_cmp
      return ar.get_plugin_cond('nvim-cmp', condition)
    end,
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
    end,
    config = function(_, opts)
      local cmp = require('cmp')
      require('cmp').setup(opts)
      ar.command('CmpInfo', function() cmp.status() end, {})
    end,
    dependencies = { 'razak17/lspkind.nvim' },
  },
}
