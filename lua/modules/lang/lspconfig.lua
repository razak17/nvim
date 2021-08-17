return function()
  local g = vim.g
  local schemas = nil
  local on_attach = require("lsp").on_attach
  local lsp_utils = require "lsp.utils"
  local status_ok, jsonls_settings = pcall(require, "nlspsettings.jsonls")

  if status_ok then
    schemas = jsonls_settings.get_default_schemas()
  end

  rvim.lang = {
    c = {
      formatters = { { exe = "clang_format", args = {}, stdin = true } },
      -- linters = { { exe = "clangtidy" } },
      linters = {},
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
        },
      },
    },
    cpp = {
      formatters = { { exe = "clang_format", args = {}, stdin = true } },
      -- linters = { { exe = "clangtidy" } },
      linters = {},
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
      formatters = {
        -- {
        --   exe = "prettier",
        --   args = {},
        -- },
        -- {
        --   exe = "prettierd",
        --   args = {},
        -- },
      },
      linters = {},
      lsp = {
        provider = "cssls",
        setup = {
          cmd = { "node", rvim.lsp.binary.css, "--stdio" },
          on_attach = on_attach,
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
        },
      },
    },
    elixir = {
      formatters = { { exe = "mix", args = {}, stdin = true } },
      linters = {},
      lsp = {
        provider = "elixirls",
        setup = {
          cmd = { rvim.lsp.binary.elixir },
          on_attach = on_attach,
        },
      },
    },
    go = {
      formatters = { { exe = "gofmt", args = {}, stdin = true } },
      linters = {
        -- { exe = "golangcilint", "revive" }
      },
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
        },
      },
    },
    html = {
      formatters = { { exe = "prettier", args = {} } },
      linters = {
        -- {
        --   exe = "tidy",
        --   -- https://docs.errata.ai/vale/scoping#html
        --   "vale",
        -- },
      },
      lsp = {
        provider = "html",
        setup = {
          cmd = { "node", rvim.lsp.binary.html, "--stdio" },
          on_attach = on_attach,
        },
      },
    },
    javascript = {
      formatters = { { exe = "prettier", args = {}, stdin = true } },
      linters = { { exe = "eslint" } },
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
      linters = { { exe = "eslint" } },
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
          cmd = { "node", rvim.lsp.binary.json, "--stdio" },
          on_attach = on_attach,
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
        stdin = true,
      } },
      linters = { { exe = "luacheck" } },
      lsp = {
        provider = "sumneko_lua",
        setup = {
          cmd = { rvim.lsp.binary.lua, "-E", g.sumneko_root_path .. "/main.lua" },
          on_attach = on_attach,
          settings = {
            Lua = {
              telemetry = {
                enable = false,
              },
              runtime = {
                version = "LuaJIT",
                path = vim.split(package.path, ";"),
              },
              diagnostics = {
                globals = { "vim", "packer_plugins" },
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
      linters = { { exe = "flake8", "pylint", "mypy" } },
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
        on_attach = on_attach,
      },
    },
    sh = {
      formatters = { {
        exe = "shfmt",
        args = {},
      } },
      linters = { { exe = "shellcheck" } },
      lsp = {
        provider = "bashls",
        setup = {
          cmd = { rvim.lsp.binary.sh, "start" },
          cmd_env = { GLOB_PATTERN = "*@(.sh|.zsh|.inc|.bash|.command)" },
          on_attach = on_attach,
        },
      },
    },
    typescript = {
      formatters = { { exe = "prettier", args = {} } },
      linters = { { exe = "eslint" } },
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
      linters = { { exe = "eslint" } },
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
      -- linters = { { exe = "vint" } },
      linters = {},
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

  local langs = {
    "c",
    "css",
    "cmake",
    "cpp",
    "docker",
    "elixir",
    "go",
    "graphql",
    "html",
    "json",
    "lua",
    "python",
    "rust",
    "sh",
    "vim",
    "yaml",
    "javascript",
    "javascriptreact",
    "typescript",
  }

  local function setup_servers()
    for _, server in ipairs(langs) do
      require("lsp").setup(server)
    end
    vim.cmd "doautocmd User LspServersStarted"
  end

  setup_servers()
  require("lsp.handlers").setup()
  require("lsp.hover").setup()
  require("lsp.signs").setup()
  lsp_utils.toggle_autoformat()
  lsp_utils.lspLocList()
end
