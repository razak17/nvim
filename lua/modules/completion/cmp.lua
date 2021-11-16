return function()
  local status_cmp_ok, cmp = rvim.safe_require "cmp"
  if not status_cmp_ok then
    return
  end

  require("core.highlights").plugin(
    "Cmp",
    { "CmpItemAbbr", { inherit = "Pmenu", gui = "NONE" } },
    { "CmpItemMenu", { inherit = "Pmenu", gui = "NONE" } },
    { "CmpItemAbbrMatch", { inherit = "qfFileName", gui = "NONE" } },
    { "CmpItemAbbrDeprecated", { gui = "strikethrough", inherit = "Comment" } },
    { "CmpItemAbbrMatchFuzzy", { gui = "italic", guifg = "fg" } }
  )

  local fn = vim.fn

  local check_backspace = function()
    local col = fn.col "." - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
  end

  local is_emmet_active = function()
    local clients = vim.lsp.buf_get_clients()

    for _, client in pairs(clients) do
      if client.name == "emmet_ls" then
        return true
      end
    end
    return false
  end

  local T = rvim.T

  rvim.cmp = {
    setup = {
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
        fields = { "kind", "abbr", "menu" },
        kind_icons = {
          Class = " ",
          Color = " ",
          Constant = "ﲀ ",
          Constructor = " ",
          Enum = "練",
          EnumMember = " ",
          Event = " ",
          Field = " ",
          File = "",
          Folder = " ",
          Function = " ",
          Interface = "ﰮ ",
          Keyword = " ",
          Method = " ",
          Module = " ",
          Operator = "",
          Property = " ",
          Reference = " ",
          Snippet = " ",
          Struct = " ",
          Text = " ",
          TypeParameter = " ",
          Unit = "塞",
          Value = " ",
          Variable = " ",
        },
        source_names = {
          nvim_lsp = "(LSP)",
          emoji = "(Emoji)",
          path = "(Path)",
          calc = "(Calc)",
          cmp_tabnine = "(Tabnine)",
          vsnip = "(Snippet)",
          luasnip = "(Snippet)",
          buffer = "(Buffer)",
        },
        duplicates = {
          buffer = 1,
          path = 1,
          nvim_lsp = 0,
          luasnip = 1,
        },
        duplicates_default = 0,
        format = function(entry, vim_item)
          vim_item.kind = rvim.cmp.setup.formatting.kind_icons[vim_item.kind]
          vim_item.menu = rvim.cmp.setup.formatting.source_names[entry.source.name]
          vim_item.dup = rvim.cmp.setup.formatting.duplicates[entry.source.name]
            or rvim.cmp.setup.formatting.duplicates_default
          return vim_item
        end,
      },
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end,
      },
      documentation = {
        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
      },
      sources = {
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "vsnip" },
        { name = "cmp_tabnine" },
        { name = "nvim_lua" },
        { name = "buffer" },
        { name = "calc" },
        { name = "emoji" },
        { name = "treesitter" },
        { name = "crates" },
      },
      mapping = {
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        -- TODO: potentially fix emmet nonsense
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif fn.call("vsnip#available", { 1 }) == 1 then
            return T "<Plug>(vsnip-expand-or-jump)"
          elseif fn.call("vsnip#jumpable", { 1 }) == 1 then
            return T "<Plug>(vsnip-jump-next)"
          elseif check_backspace() then
            fn.feedkeys(T "<Tab>", "n")
          elseif is_emmet_active() then
            return fn["cmp#complete"]()
          else
            fallback()
          end
        end, {
          "i",
          "s",
        }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif fn.call("vsnip#jumpable", { -1 }) == 1 then
            return T "<Plug>(vsnip-jump-prev)"
          else
            fallback()
          end
        end, {
          "i",
          "s",
        }),

        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping(function(fallback)
          if cmp.visible() and cmp.confirm(rvim.cmp.setup.confirm_opts) then
            return
          else
            fallback()
          end
        end),
      },
    },
  }

  require("cmp").setup(rvim.cmp.setup)

  local search_sources = {
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
      { name = "fuzzy_path" },
    }, {
      { name = "cmdline" },
    }),
  })
end
