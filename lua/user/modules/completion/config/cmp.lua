return function()
  local status_cmp_ok, cmp = rvim.safe_require("cmp")
  if not status_cmp_ok then
    return
  end

  local api = vim.api
  local t = rvim.replace_termcodes
  local border = rvim.style.border.current
  local lsp_hls = rvim.lsp.kind_highlights
  local util = require("zephyr.util")

  local kind_hls = {}
  for key, _ in pairs(lsp_hls) do
    kind_hls["CmpItemKind" .. key] = {
      inherit = lsp_hls[key],
      italic = false,
      bold = false,
      underline = false,
    }
  end

  local keyword_fg = util.get_hl("Keyword", "fg")

  util.plugin(
    "Cmp",
    vim.tbl_extend("force", {
      CmpItemAbbr = { foreground = "fg", background = "NONE", italic = false, bold = false },
      CmpItemMenu = { inherit = "NonText", italic = false, bold = false },
      CmpItemAbbrMatch = { foreground = keyword_fg },
      CmpItemAbbrDeprecated = { strikethrough = true, inherit = "Comment" },
      CmpItemAbbrMatchFuzzy = { italic = true, foreground = keyword_fg },
    }, kind_hls)
  )

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

  rvim.cmp = {
    setup = {
      preselect = cmp.PreselectMode.None,
      window = {
        completion = cmp.config.window.bordered(cmp_window),
        documentation = cmp.config.window.bordered(cmp_window),
      },
      confirm_opts = {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      },
      completion = {
        ---@usage The minimum length of a word to complete on.
        keyword_length = 1,
      },
      experimental = {
        ghost_text = true,
        native_menu = false,
      },
      formatting = {
        deprecated = true,
        fields = { "kind", "abbr", "menu" },
        source_names = {
          nvim_lsp = "(LSP)",
          nvim_lua = "(Lua)",
          luasnip = "(Luasnip)",
          path = "(Path)",
          buffer = "(Buffer)",
          cmp_tabnine = "(TN)",
          spell = "(Spell)",
          cmdline = "(Command)",
          git = "(Git)",
          calc = "(Calc)",
          emoji = "(Emoji)",
          look = "(Look)",
          npm = "(NPM)",
        },
        duplicates = {
          buffer = 1,
          path = 1,
          nvim_lsp = 0,
          luasnip = 1,
        },
        duplicates_default = 0,
        format = function(entry, vim_item)
          vim_item.kind = rvim.style.icons.kind[vim_item.kind]
          local name = entry.source.name
          local completion = entry.completion_item.data
          local menu = rvim.cmp.setup.formatting.source_names[entry.source.name]
          if name == "cmp_tabnine" then
            if completion and completion.detail then
              menu = completion.detail .. " " .. menu
            end
            vim_item.kind = ""
          end
          vim_item.menu = menu
          vim_item.dup = rvim.cmp.setup.formatting.duplicates[entry.source.name]
            or rvim.cmp.setup.formatting.duplicates_default
          return vim_item
        end,
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      sources = {
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        { name = "luasnip" },
        { name = "path" },
        { name = "buffer" },
        { name = "cmp_tabnine" },
        { name = "spell" },
        { name = "git" },
        { name = "calc" },
        { name = "emoji" },
        { name = "look" },
        { name = "nvim_lsp_document_symbol" },
        { name = "npm", keyword_length = 4 },
      },
      mapping = {
        ["<c-h>"] = cmp.mapping(function()
          api.nvim_feedkeys(vim.fn["copilot#Accept"](t("<Tab>")), "n", true)
        end),
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<Tab>"] = cmp.mapping(tab, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(shift_tab, { "i", "s" }),
        ["<C-q>"] = cmp.mapping({
          i = cmp.mapping.abort(),
          c = cmp.mapping.close(),
        }),
        ["<C-space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = false, -- If nothing is selected don't complete
        }),
      },
    },
  }

  require("cmp").setup(rvim.cmp.setup)

  local search_sources = {
    view = {
      entries = { name = "custom", direction = "bottom_up" },
    },
    sources = cmp.config.sources({
      { name = "nvim_lsp_document_symbol" },
    }, {
      { name = "fuzzy_buffer" },
    }),
  }

  cmp.setup.cmdline("/", search_sources)
  cmp.setup.cmdline("?", search_sources)
  cmp.setup.cmdline(":", {
    sources = cmp.config.sources({
      { name = "cmdline", keyword_pattern = [=[[^[:blank:]\!]*]=] },
      { name = "path" },
    }),
  })
end
