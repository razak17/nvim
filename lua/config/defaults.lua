return {
  style = {
    palette = {
      pale_red = "#E06C75",
      dark_red = "#be5046",
      light_red = "#c43e1f",
      dark_orange = "#FF922B",
      green = "#98c379",
      bright_yellow = "#FAB005",
      light_yellow = "#e5c07b",
      dark_blue = "#4e88ff",
      magenta = "#c678dd",
      comment_grey = "#5c6370",
      grey = "#3E4556",
      whitesmoke = "#626262",
      bright_blue = "#51afef",
      teal = "#15AABF",
      highlight_bg = "#4E525C",
    },
  },
  common = {
    leader = "space",
    transparent_window = false,
    line_wrap_cursor_movement = false,
    format_on_save = true,
    debug = false,
  },
  lang = {
    -- local g = vim.g
    -- local schemas = nil
    -- local status_ok, jsonls_settings = pcall(require, "nlspsettings.jsonls")

    -- if status_ok then
    --   schemas = jsonls_settings.get_default_schemas()
    -- end

    -- c = {
    --   -- formatters = { { exe = "clang_format", args = {}, stdin = true } },
    --   -- linters = { { exe = "clangtidy" } },
    --   formatters = {},
    --   linters = {},
    -- },
    -- cmake = {
    --   formatters = { { exe = "cmake_format", args = {} } },
    --   linters = {},
    -- },
    -- cpp = {
    --   formatters = { { exe = "clang_format", args = {}, stdin = true } },
    --   -- linters = { { exe = "clangtidy" } },
    --   linters = {},
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
    --   lsp = {
    --     provider = "jsonls",
    --     setup = {
    --       cmd = {
    --         "node",
    --         rvim.lsp.binary.json,
    --         "--stdio",
    --       },
    --       settings = {
    --         json = {
    --           schemas = schemas,
    --           --   = {
    --           --   {
    --           --     fileMatch = { "package.json" },
    --           --     url = "https://json.schemastore.org/package.json",
    --           --   },
    --           -- },
    --         },
    --       },
    --       commands = {
    --         Format = {
    --           function()
    --             vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line "$", 0 })
    --           end,
    --         },
    --       },
    --     },
    --   },
    -- },
    lua = {
      formatters = { {
        exe = "stylua",
        args = {},
        stdin = true,
      } },
      linters = { { exe = "luacheck" } },
    },
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
    python = {
      formatters = { { exe = "yapf", args = {}, stdin = true } },
      linters = { { exe = "flake8", "pylint", "mypy" } },
    },
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
  log = {
    ---@usage can be { "trace", "debug", "info", "warn", "error", "fatal" },
    level = "warn",
    viewer = {
      ---@usage this will fallback on "less +F" if not found
      cmd = "lnav",
      layout_config = {
        ---@usage direction = 'vertical' | 'horizontal' | 'window' | 'float',
        direction = "horizontal",
        open_mapping = "",
        size = 40,
        float_opts = {},
      },
    },
  },
}
