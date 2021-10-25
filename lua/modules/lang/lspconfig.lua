return function()
  local g = vim.g
  local schemas = nil
  local lsp_utils = require "lsp.utils"
  local status_ok, jsonls_settings = pcall(require, "nlspsettings.jsonls")

  if status_ok then
    schemas = jsonls_settings.get_default_schemas()
  end

  rvim.lang = {
    c = {
      -- formatters = { { exe = "clang_format", args = {}, stdin = true } },
      -- linters = { { exe = "clangtidy" } },
      formatters = {},
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
        },
      },
    },
    css = {
      formatters = {
        {
          exe = "prettier",
          args = {},
        },
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
          cmd = { "node", rvim.lsp.binary.tsserver, "--stdio" },
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
        },
      },
    },
    json = {
      formatters = {
        -- {
        --   exe = "json_tool",
        --   args = {},
        -- },
        -- {
        --   exe = "prettier",
        --   args = {},
        -- },
      },
      linters = {},
      lsp = {
        provider = "jsonls",
        setup = {
          cmd = {
            "node",
            rvim.lsp.binary.json,
            "--stdio",
          },
          settings = {
            json = {
              schemas = schemas,
              --   = {
              --   {
              --     fileMatch = { "package.json" },
              --     url = "https://json.schemastore.org/package.json",
              --   },
              -- },
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
      linters = { { exe = "flake8", "pylint", "mypy" } },
      lsp = {
        provider = "pyright",
        setup = {
          cmd = { rvim.lsp.binary.python, "--stdio" },
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
        setup = { cmd = { rvim.lsp.binary.rust } },
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
        },
      },
    },
  }

  local supported_languages = {
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

  for _, server in ipairs(supported_languages) do
    require("lsp").setup(server)
  end
  vim.cmd "doautocmd User LspServersStarted"

  -- require("lsp.config").setup()
  require("lsp.hover").setup()
  require("lsp.handlers").setup()

  lsp_utils.toggle_autoformat()


  local function bootstrap_nlsp(opts)
    opts = opts or {}
    local lsp_settings_status_ok, lsp_settings = pcall(require, "nlspsettings")
    if lsp_settings_status_ok then
      lsp_settings.setup(opts)
    end
  end

  bootstrap_nlsp {
    config_home = vim.g.vim_path .. "/external/nlsp-settings",
  }

  rvim.augroup("LspLocationList", {
    {
      events = { "User LspDiagnosticsChanged" },
      command = function()
        vim.lsp.diagnostic.set_loclist {
          workspace = true,
          severity_limit = "Warning",
          open_loclist = false,
        }
      end,
    },
  })
end
