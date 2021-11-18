return {
  common = {
    leader = "space",
    localleader = "space",
    transparent_window = false,
    line_wrap_cursor_movement = false,
    format_on_save = {
      ---@usage pattern string pattern used for the autocommand (Default: '*')
      pattern = "*",
      ---@usage timeout number timeout in ms for the format request (Default: 1000)
      timeout = 1000,
    },

    debug = false,
  },
  keys = {
    ---@usage change or add keymappings for normal mode
    nmap = {},

    ---@usage change or add keymappings for visual block mode
    xmap = {},

    ---@usage change or add keymappings for insert mode
    imap = {},

    ---@usage change or add keymappings for visual mode
    vmap = {},

    ---@usage change or add keymappings for operator mode
    omap = {},

    ---@usage change or add keymappings for terminal mode
    tmap = {},

    ---@usage change or add keymappings for select mode
    smap = {},

    ---@usage change or add keymappings for command mode
    cmap = {},

    ---@usage change or add keymappings for recursive normal mode
    nnoremap = {},

    ---@usage change or add keymappings for recursive visual block mode
    xnoremap = {},

    ---@usage change or add keymappings for recursive insert mode
    inoremap = {},

    ---@usage change or add keymappings for recursive visual mode
    vnoremap = {},

    ---@usage change or add keymappings for recursive operator mode
    onoremap = {},

    ---@usage change or add keymappings for recursive terminal mode
    tnoremap = {},

    ---@usage change or add keymappings for recursive select mode
    snoremap = {},

    ---@usage change or add keymappings for recursive command mode
    cnoremap = {},
  },
  style = {
    palette = {
      bg = "#282a36",
      statusline_bg = "#373d48",
      statusline_section_bg = "#2f333b",
      statusline_fg = "#c8ccd4",
      highlight_bg = "#4E525C",
      pale_red = "#E06C75",
      red = "#be5046",
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
      cyan = "#56b6c2",
      orange = "#ffb86c",
    },
    kinds = {
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
    lua = {
      formatters = { {
        exe = "stylua",
        args = {},
        stdin = true,
      } },
      linters = {
        -- { exe = "luacheck" }
      },
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
}
