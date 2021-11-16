return {
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
  plugin = {
    commits = {
      autopairs = "f858ab38b532715dbaf7b2773727f8622ba04322",
      null_ls = "64b269b51c7490660dcb2008f59ae260f2cdbbe4",
      lsp_config = "6224c54a9945a52bf43a8bc1a42a112084590c0b",
    },
    -- SANE defaults
    SANE = { active = false },
    packer = { active = true },
    -- debug
    dap = { active = false },
    dap_ui = { active = false },
    dap_install = { active = false },
    osv = { active = false },
    -- lsp
    lspconfig = { active = true },
    lsp_installer = { active = true },
    fix_cursorhold = { active = false },
    nlsp = { active = true },
    null_ls = { active = true },
    lightbulb = { active = false },
    symbols_outline = { active = false },
    bqf = { active = false },
    trouble = { active = false },
    -- treesitter
    treesitter = { active = true },
    playground = { active = true },
    autopairs = { active = true },
    rainbow = { active = false },
    autotag = { active = true },
    matchup = { active = true },
    -- editor
    ajk = { active = true },
    easy_align = { active = true },
    cool = { active = true },
    surround = { active = true },
    colorizer = { active = false },
    kommentary = { active = true },
    dial = { active = true },
    fold_cycle = { active = false },
    cursorword = { active = false },
    -- tools
    fterm = { active = true },
    far = { active = true },
    bookmarks = { active = false },
    undotree = { active = true },
    fugitive = { active = false },
    project = { active = true },
    diffview = { active = false },
    -- TODO: handle these later
    glow = { active = false },
    doge = { active = false },
    dadbod = { active = false },
    restconsole = { active = false },
    markdown_preview = { active = false },
    -- aesth
    tree = { active = true },
    dashboard = { active = true },
    statusline = { active = true },
    bufferline = { active = true },
    devicons = { active = true },
    git_signs = { active = true },
    indent_line = { active = true },
    -- completion
    which_key = { active = true },
    plenary = { active = true },
    popup = { active = true },
    telescope = { active = true },
    cmp = { active = true },
    vsnip = { active = true },
    emmet = { active = false },
    friendly_snippets = { active = true },
    telescope_fzf = { active = true },
  },
}
