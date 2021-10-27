return function()
  local status_cmp_ok, cmp = pcall(require, "cmp")
  if not status_cmp_ok then
    return
  end

  local fn = vim.fn
  local T = rvim.T

  local check_backspace = function()
    local col = vim.fn.col "." - 1
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

  rvim.cmp = {
    setup = {
      confirm_opts = {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      },
      experimental = {
        ghost_text = true,
        native_menu = false,
      },
      formatting = {
        kind_icons = rvim.style.kinds,
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
          vsnip = 1,
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
        ["<Tab>"] = cmp.mapping(function()
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
            vim.fn.feedkeys(T "<Tab>", "n")
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

  -- Use buffer source for `/`.
  cmp.setup.cmdline("/", {
    sources = {
      { name = "buffer" },
    },
  })

  cmp.setup.cmdline("?", {
    sources = {
      { name = "buffer" },
    },
  })

  -- Use cmdline & path source for ':'.
  cmp.setup.cmdline(":", {
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      { name = "cmdline" },
    }),
  })
end
