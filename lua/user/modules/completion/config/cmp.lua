return function()
  local status_cmp_ok, cmp = rvim.safe_require("cmp")
  if not status_cmp_ok then
    return
  end

  local fn = vim.fn
  local api = vim.api

  local t = rvim.replace_termcodes
  local border = rvim.style.border.current
  local lsp_hls = rvim.lsp.kind_highlights
  local util = require("user.utils.highlights")
  local ellipsis = rvim.style.icons.misc.ellipsis

  local kind_hls = rvim.fold(
    function(accum, value, key)
      accum["CmpItemKind" .. key] = { foreground = { from = value } }
      return accum
    end,
    lsp_hls,
    {
      CmpItemAbbr = { foreground = "fg", background = "NONE", italic = false, bold = false },
      CmpItemAbbrDeprecated = { strikethrough = true, inherit = "Comment" },
      CmpItemAbbrMatchFuzzy = { italic = true, foreground = { from = "Keyword" } },
    }
  )

  util.plugin("Cmp", kind_hls)

  local cmp_window = {
    border = border,
    winhighlight = table.concat({
      "Normal:NormalFloat",
      "FloatBorder:FloatBorder",
      "CursorLine:Visual",
      completion = {
        -- TODO: consider 'shadow', and tweak the winhighlight
        border = border,
      },
      documentation = {
        border = border,
      },
      "Search:None",
    }, ","),
  }

  ---checks if the character preceding the cursor is a space character
  ---@return boolean true if it is a space character, false otherwise
  local check_backspace = function()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
  end

  ---checks if emmet_ls is available and active in the buffer
  ---@return boolean true if available, false otherwise
  local is_emmet_active = function()
    local clients = vim.lsp.buf_get_clients()

    for _, client in pairs(clients) do
      if client.name == "emmet_ls" then
        return true
      end
    end
    return false
  end

  local function tab(fallback)
    local ok, luasnip = rvim.safe_require("luasnip", { silent = true })
    if cmp.visible() then
      cmp.select_next_item()
    elseif ok and luasnip.expand_or_locally_jumpable() then
      luasnip.expand_or_jump()
    elseif check_backspace() then
      fallback()
    elseif is_emmet_active() then
      return vim.fn["cmp#complete"]()
    else
      fallback()
    end
  end

  local function shift_tab(fallback)
    local ok, luasnip = rvim.safe_require("luasnip", { silent = true })
    if cmp.visible() then
      cmp.select_prev_item()
    elseif ok and luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      fallback()
    end
  end

  rvim.cmp = {
    setup = {
      preselect = cmp.PreselectMode.None,
      window = {
        completion = cmp.config.window.bordered(cmp_window),
        documentation = cmp.config.window.bordered(cmp_window),
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      mapping = {
        ["<c-h>"] = cmp.mapping(function()
          api.nvim_feedkeys(fn["copilot#Accept"](t("<Tab>")), "n", true)
        end),
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
        ["<Tab>"] = cmp.mapping(tab, { "i", "s", "c" }),
        ["<S-Tab>"] = cmp.mapping(shift_tab, { "i", "s", "c" }),
        ["<C-q>"] = cmp.mapping({
          i = cmp.mapping.abort(),
          c = cmp.mapping.close(),
        }),
        ["<C-space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }), -- If nothing is selected don't complete
      },
      formatting = {
        deprecated = true,
        fields = { "kind", "abbr", "menu" },
        source_names = {
          copilot = "(CP)",
          nvim_lsp = "(LSP)",
          nvim_lua = "(Lua)",
          luasnip = "(SN)",
          path = "(Path)",
          buffer = "(Buf)",
          spell = "(SP)",
          cmdline = "(Cmd)",
          git = "(Git)",
          calc = "(Calc)",
          emoji = "(E)",
          look = "(Look)",
          npm = "(NPM)",
          dictionary = "(Dict)",
          cmdline_history = "(Hist)",
        },
        format = function(entry, vim_item)
          local MAX = math.floor(vim.o.columns * 0.5)
          vim_item.abbr = #vim_item.abbr >= MAX and string.sub(vim_item.abbr, 1, MAX) .. ellipsis
            or vim_item.abbr
          if entry.source.name == "copilot" then
            vim_item.kind = rvim.style.icons.misc.octoface
          else
            vim_item.kind = rvim.style.codicons.kind[vim_item.kind]
          end
          vim_item.menu = rvim.cmp.setup.formatting.source_names[entry.source.name]
          return vim_item
        end,
      },
      sources = {
        { name = "copilot" },
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        { name = "luasnip" },
        { name = "path" },
        {
          name = "buffer",
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
        { name = "cmp_tabnine" },
        { name = "spell" },
        { name = "git" },
        { name = "calc" },
        { name = "emoji" },
        { name = "look" },
        { name = "nvim_lsp_document_symbol" },
        { name = "npm", keyword_length = 4 },
        { name = "cmdline_history" },
      },
    },
  }

  require("cmp").setup(rvim.cmp.setup)

  local search_sources = {
    view = { entries = { name = "custom", selection_order = "near_cursor" } },

    sources = cmp.config.sources({
      { name = "nvim_lsp_document_symbol" },
    }, {
      { name = "buffer" },
    }),
  }

  cmp.setup.cmdline("/", search_sources)
  cmp.setup.cmdline("?", search_sources)
  cmp.setup.cmdline(":", {
    sources = cmp.config.sources({
      { name = "cmdline", keyword_pattern = [=[[^[:blank:]\!]*]=] },
      { name = "cmdline_history" },
      { name = "path" },
    }),
  })

  -- FIXME: this should not be required if we were using a prompt buffer in telescope i.e. prompt prefix
  -- Deactivate cmp in telescope prompt buffer
  rvim.augroup("CmpConfig", {
    {
      event = { "FileType" },
      pattern = { "TelescopePrompt" },
      command = function()
        cmp.setup.buffer({ completion = { autocomplete = false } })
      end,
    },
  })
end
