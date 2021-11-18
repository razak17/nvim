return {
  servers = {
    "clangd",
    "cssls",
    "cmake",
    "dockerls",
    "elixirls",
    "emmet_ls",
    "gopls",
    "graphql",
    "html",
    "jsonls",
    "sumneko_lua",
    "pyright",
    "rust_analyzer",
    "bashls",
    "vimls",
    "yamlls",
    "tsserver",
    "eslint",
  },
  colors = {
    error = rvim.style.palette.pale_red,
    warn = rvim.style.palette.dark_orange,
    info = rvim.style.palette.bright_blue,
    hint = rvim.style.palette.teal,
  },
  completion = {
    item_kind = {
      "   (Text) ",
      "   (Method)",
      " ƒ  (Function)",
      "   (Constructor)",
      " ﴲ  (Field)",
      "   (Variable)",
      "   (Class)",
      " ﰮ  (Interface)",
      "   (Module)",
      " 襁 (Property)",
      "   (Unit)",
      "   (Value)",
      " 了 (Enum)",
      "   (Keyword)",
      "   (Snippet)",
      "   (Color)",
      "   (File)",
      "   (Reference)",
      "   (Folder)",
      "   (EnumMember)",
      "   (Constant)",
      " ﳤ  (Struct)",
      " 鬒 (Event)",
      "   (Operator)",
      "   (TypeParameter)",
    },
  },
  diagnostics = {
    signs = {
      active = false,
      values = {
        { name = "LspDiagnosticsSignError", text = "" },
        { name = "LspDiagnosticsSignWarning", text = "" },
        { name = "LspDiagnosticsSignInformation", text = "" },
        { name = "LspDiagnosticsSignHint", text = "" },
      },
    },
    virtual_text = {
      prefix = "",
      spacing = 2,
    },
    underline = true,
    update_in_insert = false,
    severity_sort = false,
  },
  null_ls = {
    setup = {
      -- root_dir = require("lspconfig").util.root_pattern("Makefile", ".git", "node_modules"),
    },
    config = {},
  },
  override = {
    "angularls",
    "ansiblels",
    "denols",
    "ember",
    "jedi_language_server",
    "pylsp",
    "rome",
    "sqlls",
    "sqls",
    "stylelint_lsp",
    "tailwindcss",
    "volar",
  },
  automatic_servers_installation = true,
  on_attach_callback = nil,
  on_init_callback = nil,
  document_highlight = true,
  code_lens_refresh = true,
  hover_diagnostics = false,
  lint_on_save = false,
  popup_border = "single",
  lang = {
    -- c = {
    --   -- formatters = { { exe = "clang_format", args = {}, stdin = true } },
    --   -- linters = { { exe = "clangtidy" } },
    -- },
    -- cmake = {
    --   formatters = { { exe = "cmake_format", args = {} } },
    --   linters = {},
    -- },
    -- cpp = {
    --   formatters = { { exe = "clang_format", args = {}, stdin = true } },
    --   -- linters = { { exe = "clangtidy" } },
    -- },
    -- css = {
    --   formatters = {
    --     {
    --       exe = "prettier",
    --       args = {},
    --     },
    --     -- {
    --     --   exe = "prettierd",
    --     --   args = {},
    --     -- },
    --   },
    --   linters = {},
    -- },
    -- docker = {
    --   formatters = { { exe = "", args = {} } },
    --   linters = {},
    -- },
    -- elixir = {
    --   formatters = { { exe = "mix", args = {}, stdin = true } },
    --   linters = {},
    -- },
    -- go = {
    --   formatters = { { exe = "gofmt", args = {}, stdin = true } },
    --   linters = {
    --     -- { exe = "golangcilint", "revive" }
    --   },
    -- },
    -- graphql = {
    --   formatters = { { exe = "", args = {} } },
    --   linters = {},
    -- },
    -- html = {
    --   formatters = { { exe = "prettier", args = {} } },
    --   linters = {
    --     -- {
    --     --   exe = "tidy",
    --     --   -- https://docs.errata.ai/vale/scoping#html
    --     --   "vale",
    --     -- },
    --   },
    -- },
    -- javascript = {
    --   formatters = { { exe = "prettier", args = {}, stdin = true } },
    --   linters = { { exe = "eslint" } },
    -- },
    -- javascriptreact = {
    --   -- @usage can be prettier or eslint
    --   formatters = { { exe = "prettier", args = {}, stdin = true } },
    --   linters = { { exe = "eslint" } },
    -- },
    -- json = {
    --   formatters = {
    --     -- {
    --     --   exe = "json_tool",
    --     --   args = {},
    --     -- },
    --     -- {
    --     --   exe = "prettier",
    --     --   args = {},
    --     -- },
    --   },
    --   linters = {},
    -- },
    -- lua = {
    --   formatters = { {
    --     exe = "stylua",
    --     args = {},
    --     stdin = true,
    --   } },
    --   linters = {
    --     -- { exe = "luacheck" }
    --   },
    -- },
    -- nginx = {
    --   formatters = {
    --     {
    --       exe = "nginx_beautifier",
    --       args = {
    --         provider = "",
    --         setup = {},
    --       },
    --     },
    --   },
    --   linters = {},
    -- },
    -- python = {
    --   formatters = { { exe = "yapf", args = {}, stdin = true } },
    --   linters = { { exe = "flake8", "pylint", "mypy" } },
    -- },
    -- r = {
    --   formatters = { {
    --     exe = "format_r",
    --     args = {},
    --   } },
    --   linters = {},
    -- },
    -- rust = {
    --   formatters = { { exe = "rustfmt", args = { "--emit=stdout", "--edition=2018" }, stdin = true } },
    --   linters = {},
    -- },
    -- sh = {
    --   formatters = { {
    --     exe = "shfmt",
    --     args = {},
    --   } },
    --   linters = { { exe = "shellcheck" } },
    -- },
    -- typescript = {
    --   formatters = { { exe = "prettier", args = {} } },
    --   linters = { { exe = "eslint" } },
    -- },
    -- typescriptreact = {
    --   formatters = { { exe = "prettier", args = {}, stdin = true } },
    --   linters = { { exe = "eslint" } },
    -- },
    -- vim = {
    --   formatters = { exe = "", args = {} },
    --   -- linters = { { exe = "vint" } },
    --   linters = {},
    -- },
    -- yaml = {
    --   formatters = {
    --     {
    --       exe = "prettier",
    --       args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0), "--single-quote", stdin = true },
    --       stdin = true,
    --     },
    --   },
    --   linters = {},
    -- },
  },
}
