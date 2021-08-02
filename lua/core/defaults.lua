local g = vim.g

-- common
rvim.common = {
  leader_key = " ",
  transparent_window = false,
  line_wrap_cursor_movement = true,
  format_on_save = true,
  debug = false,
}

-- Consistent store of various UI items to reuse throughout my config
rvim.style = {
  icons = {
    error = "",
    warn = "",
    info = "",
    hint = "",
  },
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
}

-- opts
rvim.sets = {
  wrap = false,
  spell = false,
  spelllang = "en",
  textwidth = 100,
  tabstop = 2,
  cmdheight = 2,
  shiftwidth = 2,
  numberwidth = 4,
  scrolloff = 7,
  laststatus = 2,
  showtabline = 2,
  smartcase = true,
  ignorecase = true,
  hlsearch = true,
  timeoutlen = 500,
  foldenable = true,
  foldtext = "v:lua.folds()",
  udir = vim.g.cache_dir .. "/undodir",
  viewdir = vim.g.cache_dir .. "view",
  directory = vim.g.cache_dir .. "/swap",
}

-- toogle plugins easily
rvim.plugin = {
  -- SANE defaults
  SANE = { active = true },
  -- debug
  debug = { active = false },
  debug_ui = { active = false },
  dap_install = { active = false },
  osv = { active = false },
  -- lsp
  saga = { active = false },
  lightbulb = { active = true },
  symbols_outline = { active = false },
  bqf = { active = false },
  trouble = { active = false },
  nvim_lint = { active = false },
  formatter = { active = false },
  lsp_ts_utils = { active = true },
  -- treesitter
  treesitter = { active = false },
  playground = { active = true },
  rainbow = { active = false },
  matchup = { active = false },
  autotag = { active = false },
  autopairs = { active = true },
  -- editor
  fold_cycle = { active = false },
  accelerated_jk = { active = false },
  easy_align = { active = false },
  cool = { active = true },
  delimitmate = { active = false },
  eft = { active = false },
  cursorword = { active = false },
  surround = { active = true },
  dial = { active = true },
  -- tools
  fterm = { active = true },
  far = { active = true },
  bookmarks = { active = false },
  colorizer = { active = true },
  undotree = { active = false },
  fugitive = { active = false },
  rooter = { active = true },
  diffview = { active = true },
  -- TODO: handle these later
  glow = { active = false },
  doge = { active = false },
  dadbod = { active = false },
  restconsole = { active = false },
  markdown_preview = { active = true },
  -- aesth
  tree = { active = true },
  dashboard = { active = false },
  statusline = { active = false },
  git_signs = { active = false },
  indent_line = { active = false },
  -- completion
  emmet = { active = false },
  friendly_snippets = { active = true },
  vsnip = { active = true },
  telescope_fzy = { active = false },
  telescope_project = { active = false },
  telescope_media_files = { active = false },
}

rvim.lsp = {
  override = {},
  document_highlight = true,
  diagnostics = {
    signs = {
      active = true,
      values = {
        { name = "LspDiagnosticsSignError", text = rvim.style.icons.error },
        { name = "LspDiagnosticsSignWarning", text = rvim.style.icons.warn },
        { name = "LspDiagnosticsSignHint", text = rvim.style.icons.hint },
        { name = "LspDiagnosticsSignInformation", text = rvim.style.icons.info },
      },
    },
    virtual_text = {
      prefix = "",
      spacing = 0,
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  },
  hover_diagnostics = true,
  lint_on_save = true,
  popup_border = "single",
  binary = {
    clangd = "clangd",
    cmake = "cmake-language-server",
    css = "vscode-css-language-server",
    docker = "docker-langserver",
    efm = "efm-langserver",
    elixir = g.elixirls_root_path .. "/.bin/language_server.sh",
    graphql = "graphql-lsp",
    lua = g.sumneko_root_path .. "/bin/Linux/lua-language-server",
    go = "gopls",
    html = "vscode-html-language-server",
    json = "vscode-json-language-server",
    python = "pyright-langserver",
    rust = "rust-analyzer",
    sh = "bash-language-server",
    tsserver = "typescript-language-server",
    vim = "vim-language-server",
    yaml = "yaml-language-server",
  },
}

local schemas = nil
local on_attach = require("lsp").on_attach
local lsp_utils = require "lsp.utils"
local root_dir = lsp_utils.root_dir

local status_ok, jsonls_settings = pcall(require, "nlspsettings.jsonls")
if status_ok then
  schemas = jsonls_settings.get_default_schemas()
end

rvim.lang = {
  c = {
    formatters = { { exe = "clang_format", args = {}, stdin = true } },
    linters = { "clangtidy" },
    lsp = {
      provider = "clangd",
      setup = {
        cmd = {
          rvim.lsp.binary.clangd,
          "--background-index",
          "--header-insertion=never",
          "--cross-file-rename",
          "--clang-tidy",
          "--header-insertion=never",
          "--cross-file-rename",
          "--clang-tidy",
          "--clang-tidy-checks=-*,llvm-*,clang-analyzer-*",
        },
        init_options = {
          clangdFileStatus = true,
          usePlaceholders = true,
          completeUnimported = true,
          semanticHighlighting = true,
        },
        on_attach = on_attach,
      },
    },
  },
  cmake = {
    formatters = { { exe = "cmake_format", args = {} } },
    linters = {},
    lsp = {
      provider = "cmake",
      setup = {
        cmd = { rvim.lsp.binary.cmake, "--stdio" },
        on_attach = on_attach,
        root_dir = root_dir,
      },
    },
  },
  cpp = {
    formatters = { { exe = "clang_format", args = {}, stdin = true } },
    linters = { "cppcheck", "clangtidy" },
    lsp = {
      provider = "clangd",
      setup = {
        cmd = {
          rvim.lsp.binary.clangd,
          "--background-index",
          "--header-insertion=never",
          "--cross-file-rename",
          "--completion-style=bundled",
          "--clang-tidy",
          "--clang-tidy-checks=-*,llvm-*,clang-analyzer-*",
        },
        init_options = {
          clangdFileStatus = true,
          usePlaceholders = true,
          completeUnimported = true,
          semanticHighlighting = true,
        },
        on_attach = on_attach,
      },
    },
  },
  css = {
    formatters = { { exe = "prettier", args = {} } },
    linters = {},
    lsp = {
      provider = "cssls",
      setup = {
        cmd = { rvim.lsp.binary.css, "--stdio" },
        on_attach = on_attach,
        root_dir = root_dir,
      },
    },
  },
  docker = {
    formatters = { { exe = "", args = {} } },
    linters = {},
    lsp = {
      provider = "dockerls",
      setup = {
        cmd = { rvim.lsp.binary.docker, "--stdio" },
        on_attach = on_attach,
        root_dir = root_dir,
      },
    },
  },
  elixir = {
    formatters = { { exe = "mix", args = {}, stdin = true } },
    linters = {},
    lsp = {
      provider = "elixirls",
      setup = { cmd = { rvim.lsp.binary.elixir }, on_attach = on_attach },
    },
  },
  go = {
    formatters = { { exe = "gofmt", args = {}, stdin = true } },
    linters = { "golangcilint", "revive" },
    lsp = {
      provider = "gopls",
      setup = {
        cmd = { rvim.lsp.binary.go },
        on_attach = on_attach,
      },
    },
  },
  graphql = {
    formatters = { { exe = "", args = {} } },
    linters = {},
    lsp = {
      provider = "graphql",
      setup = {
        cmd = { rvim.lsp.binary.graphql, "server", "-m", "stream" },
        on_attach = on_attach,
        root_dir = root_dir,
      },
    },
  },
  html = {
    formatters = { { exe = "prettier", args = {} } },
    linters = {
      "tidy",
      -- https://docs.errata.ai/vale/scoping#html
      "vale",
    },
    lsp = {
      provider = "html",
      setup = {
        cmd = { rvim.lsp.binary.html, "--stdio" },
        on_attach = on_attach,
        root_dir = root_dir,
      },
    },
  },
  javascript = {
    formatters = { { exe = "prettier", args = {} } },
    linters = { "eslint" },
    lsp = {
      provider = "tsserver",
      setup = {
        -- TODO:
        cmd = { rvim.lsp.binary.tsserver, "--stdio" },
        on_attach = on_attach,
      },
    },
  },
  javascriptreact = {
    -- @usage can be prettier or eslint
    formatters = { { exe = "prettier", args = {}, stdin = true } },
    linters = { "eslint" },
    lsp = {
      provider = "tsserver",
      setup = {
        -- TODO:
        cmd = { rvim.lsp.binary.tsserver, "--stdio" },
        on_attach = on_attach,
      },
    },
  },
  json = {
    formatters = { { exe = "json_tool", args = {}, stdin = true } },
    linters = {},
    lsp = {
      provider = "jsonls",
      setup = {
        cmd = { rvim.lsp.binary.json, "--stdio" },
        on_attach = on_attach,
        root_dir = root_dir,
        settings = {
          json = {
            schemas = schemas,
          },
        },
        commands = {
          Format = {
            function()
              vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line "$", 0 })
            end,
          },
        },
      },
    },
  },
  lua = {
    formatters = { {
      exe = "stylua",
      args = {},
    } },
    linters = { "luacheck" },
    lsp = {
      provider = "sumneko_lua",
      setup = {
        cmd = { rvim.lsp.binary.lua, "-E", g.sumneko_root_path .. "/main.lua" },
        on_attach = on_attach,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
              path = vim.split(package.path, ";"),
            },
            diagnostics = {
              globals = { "vim", "packer_plugins", "rvim" },
            },
            workspace = {
              library = {
                [vim.fn.expand "$VIMRUNTIME/lua"] = true,
                [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
              },
              maxPreload = 100000,
              preloadFileSize = 1000,
            },
          },
        },
      },
    },
  },
  nginx = {
    formatters = {
      {
        exe = "nginx_beautifier",
        args = {
          provider = "",
          setup = {},
        },
      },
    },
    linters = {},
    lsp = {},
  },
  python = {
    formatters = { { exe = "yapf", args = {}, stdin = true } },
    linters = { "flake8", "pylint", "mypy" },
    lsp = {
      provider = "pyright",
      setup = {
        cmd = { rvim.lsp.binary.python, "--stdio" },
        on_attach = on_attach,
      },
    },
  },
  r = {
    formatters = { {
      exe = "format_r",
      args = {},
    } },
    linters = {},
  },
  rust = {
    formatters = { { exe = "rustfmt", args = { "--emit=stdout", "--edition=2018" }, stdin = true } },
    linters = {},
    lsp = {
      provider = "rust_analyzer",
      setup = { cmd = { rvim.lsp.binary.rust }, on_attach = on_attach },
    },
  },
  sh = {
    formatters = { {
      exe = "shfmt",
      args = {},
    } },
    linters = { "shellcheck" },
    lsp = {
      provider = "bashls",
      setup = {
        cmd = { rvim.lsp.binary.sh, "start" },
        cmd_env = { GLOB_PATTERN = "*@(.sh|.zsh|.inc|.bash|.command)" },
        filetypes = { "sh", "zsh" },
        on_attach = on_attach,
      },
    },
  },
  typescript = {
    formatters = { { exe = "prettier", args = {} } },
    linters = { "eslint" },
    lsp = {
      provider = "tsserver",
      setup = {
        -- TODO:
        cmd = { rvim.lsp.binary.tsserver, "--stdio" },
        on_attach = on_attach,
      },
    },
  },
  typescriptreact = {
    formatters = { { exe = "prettier", args = {}, stdin = true } },
    linters = { "eslint" },
    lsp = {
      provider = "tsserver",
      setup = {
        -- TODO:
        cmd = { rvim.lsp.binary.tsserver, "--stdio" },
        on_attach = on_attach,
      },
    },
  },
  vim = {
    formatters = { exe = "", args = {} },
    linters = { "vint" },
    lsp = {
      provider = "vimls",
      setup = {
        cmd = { rvim.lsp.binary.vim, "--stdio" },
        on_attach = on_attach,
      },
    },
  },
  yaml = {
    formatters = {
      {
        exe = "prettier",
        args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0), "--single-quote", stdin = true },
        stdin = true,
      },
    },
    linters = {},
    lsp = {
      provider = "yamlls",
      setup = {
        cmd = { rvim.lsp.binary.yaml, "--stdio" },
        on_attach = on_attach,
      },
    },
  },
}
