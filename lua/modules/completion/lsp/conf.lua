local ex = vim.fn.executable
local lspconfig = require 'lspconfig'
local rpattern = require'lspconfig.util'.root_pattern
local G = require 'core.global'
local M = {}

function M.setup(enhance_attach)
  if ex("bash-language-server") then
    lspconfig.bashls.setup {
      cmd_env = { GLOB_PATTERN = "*@(.sh|.zsh|.inc|.bash|.command)" },
      filetypes = { "sh", "zsh" },
      on_attach = enhance_attach
    }
  end

  if ex(G.elixirls_binary) then
    lspconfig.elixirls.setup {
      cmd = { G.elixirls_root_path .. ".bin/language_server.sh" },
      elixirls = { dialyzerEnabled = false },
      on_attach = enhance_attach,
    }
  end

  if ex(G.sumneko_binary) then
    lspconfig.sumneko_lua.setup {
      on_attach = enhance_attach,
      cmd = {G.sumneko_binary, "-E", G.sumneko_root_path .. "/main.lua"},
      settings = {
        Lua = {
          runtime = {version = "LuaJIT", path = vim.split(package.path, ';')},
          diagnostics = {
            globals = {"vim", "map", "filter", "range", "reduce", "head", "tail", "nth", "use"},
          },
          workspace = {
            library = {
              [vim.fn.expand('$VIMRUNTIME/lua')] = true,
              [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
            },
          }
        }
      }
    }
  end

  if ex("typescript-language-server") then
    lspconfig.tsserver.setup {
      root_dir = rpattern('tsconfig.json', 'package.json', '.git', vim.fn.getcwd()),
      settings = { documentFormatting = false },
      on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
        enhance_attach(client, bufnr)
      end
    }
  end

  if ex("pyright") then
    lspconfig.pyright.setup {
      on_attach = enhance_attach
    }
  end

  if ex("clangd") then
    lspconfig.clangd.setup {
      cmd = {
      'clangd',
      "--background-index",
      '--clang-tidy',
      '--completion-style=bundled',
      '--header-insertion=iwyu',
      '--suggest-missing-includes',
      '--cross-file-rename'
      },
      init_options = {
        clangdFileStatus = true,
        usePlaceholders = true,
        completeUnimported = true,
        semanticHighlighting = true
      },
      on_attach = enhance_attach
    }
  end

  if ex("rust-analyzer") then
    lspconfig.rust_analyzer.setup {
      checkOnSave = {
          command = "clippy"
      },
      on_attach = enhance_attach
    }
  elseif ex("rls") then
    lspconfig.rls.setup {
      on_attach = enhance_attach
    }
  end

  local simple_lsp = {
    gopls = "gopls",
    jsonls = "vscode-json-languageserver",
    cssls = "css-languageserver",
    dockerls = "docker-langserver",
    graphql = "graphql-lsp",
    html = "html-languageserver",
    svelte= "svelteserver",
    vimls = "vim-language-server",
    yamlls = "yaml-language-server",
  }

  for lsp, exec in pairs(simple_lsp) do
    if ex(exec) then
      lspconfig[lsp].setup {
        on_attach = enhance_attach,
        root_dir = rpattern('.git', '.gitignore', vim.fn.getcwd()),
      }
    end
  end
end

return M
