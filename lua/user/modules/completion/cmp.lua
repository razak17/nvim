return function()
  local status_cmp_ok, cmp = rvim.safe_require "cmp"
  if not status_cmp_ok then
    return
  end

  require("zephyr.util").plugin(
    "Cmp",
    { "CmpItemAbbr", { inherit = "Comment", italic = false, bold = false } },
    { "CmpItemMenu", { inherit = "NonText", italic = false, bold = false } },
    { "CmpItemAbbrMatch", { bold = true } },
    { "CmpItemAbbrDeprecated", { strikethrough = true, inherit = "Comment" } },
    { "CmpItemAbbrMatchFuzzy", { italic = true, foreground = "fg" } }
  )

  local lsp_hls = rvim.lsp.kind_highlights
  local fmt = string.format

  local kind_hls = vim.tbl_map(function(key)
    return {
      fmt("CmpItemKind%s", key),
      { inherit = lsp_hls[key], italic = false, bold = false, underline = false },
    }
  end, vim.tbl_keys(
    lsp_hls
  ))

  require("zephyr.util").plugin("CmpKinds", unpack(kind_hls))

  -- FIXME: this should not be required if we were using a prompt buffer in telescope i.e. prompt prefix
  -- Deactivate cmp in telescope prompt buffer
  rvim.augroup("CmpConfig", {
    {
      event = { "FileType" },
      pattern = { "TelescopePrompt" },
      command = function()
        cmp.setup.buffer { completion = { autocomplete = false } }
      end,
    },
  })

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

  local T = rvim.replace_termcodes

  rvim.cmp = {
    setup = {
      window = {
        completion = {
          -- TODO: consider 'shadow', and tweak the winhighlight
          border = "rounded",
        },
        documentation = {
          border = "rounded",
        },
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
          vsnip = "(Snippet)",
          path = "(Path)",
          buffer = "(Buffer)",
          cmp_tabnine = "(TN)",
          spell = "(Spell)",
          cmdline = "(Command)",
          cmp_git = "(Git)",
          calc = "(Calc)",
          emoji = "(Emoji)",
          look = "(Look)",
        },
        duplicates = {
          buffer = 1,
          path = 1,
          nvim_lsp = 0,
          luasnip = 1,
        },
        duplicates_default = 0,
        format = function(entry, vim_item)
          vim_item.kind = rvim.kind_icons[vim_item.kind]
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
          vim.fn["vsnip#anonymous"](args.body)
        end,
      },
      documentation = {
        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
      },
      sources = {
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        { name = "vsnip" },
        { name = "path" },
        { name = "buffer" },
        { name = "cmp_tabnine" },
        { name = "spell" },
        { name = "cmp_git" },
        { name = "calc" },
        { name = "emoji" },
        { name = "look" },
        { name = "nvim_lsp_document_symbol" },
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
        ["<CR>"] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
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
      { name = "cmdline", keyword_pattern = [=[[^[:blank:]\!]*]=] },
    }),
  })
end
