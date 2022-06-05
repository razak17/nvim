return function()
  local ls = require("luasnip")
  local types = require("luasnip.util.types")
  local extras = require("luasnip.extras")
  local fmt = require("luasnip.extras.fmt").fmt

  ls.config.set_config({
    history = false,
    region_check_events = "CursorMoved,CursorHold,InsertEnter",
    delete_check_events = "InsertLeave",
    ext_opts = {
      [types.choiceNode] = {
        active = {
          hl_mode = "combine",
          virt_text = { { "●", "Operator" } },
        },
      },
      [types.insertNode] = {
        active = {
          hl_mode = "combine",
          virt_text = { { "●", "Type" } },
        },
      },
    },
    enable_autosnippets = true,
    snip_env = {
      fmt = fmt,
      m = extras.match,
      t = ls.text_node,
      f = ls.function_node,
      c = ls.choice_node,
      d = ls.dynamic_node,
      i = ls.insert_node,
      l = extras.lamda,
      snippet = ls.snippet,
    },
  })

  rvim.command("LuaSnipEdit", function()
    require("luasnip.loaders.from_lua").edit_snippet_files()
  end)

  -- FIXME: Doesn't work
  require("which-key").register({
    ["<leader>S"] = { ":LuaSnipEdit<CR> 1<CR><CR>", "edit snippet" },
  })

  -- <c-l> is selecting within a list of options.
  vim.keymap.set({ "s", "i" }, "<c-l>", function()
    if ls.choice_active() then
      ls.change_choice(1)
    end
  end)

  vim.keymap.set({ "s", "i" }, "<c-j>", function()
    if ls.expand_or_jumpable() then
      ls.expand_or_jump()
    end
  end)

  -- <C-K> is easier to hit but swallows the digraph key
  vim.keymap.set({ "s", "i" }, "<c-b>", function()
    if ls.jumpable(-1) then
      ls.jump(-1)
    end
  end)

  require("luasnip").config.setup({ store_selection_keys = "<C-x>" })

  local utils = require("user.utils")
  local paths = {
    join_paths(rvim.get_runtime_dir(), "site", "pack", "packer", "start", "friendly-snippets"),
  }
  local user_snippets = rvim.paths.snippets
  if utils.is_directory(user_snippets) then
    paths[#paths + 1] = user_snippets
  end
  require("luasnip.loaders.from_lua").lazy_load()
  require("luasnip.loaders.from_vscode").lazy_load({
    paths = paths,
  })
  require("luasnip.loaders.from_snipmate").lazy_load()

  -- Enable react snippets in js and ts files
  require("luasnip").filetype_extend("javascript", { "javascriptreact" })
  require("luasnip").filetype_extend("typescript", { "typescriptreact" })
end
