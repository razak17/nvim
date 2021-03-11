local vim, ex = vim, vim.fn.executable
local lspconfig = require 'lspconfig'
local rpattern = require'lspconfig.util'.root_pattern
local on_attach = require 'modules.completion.lsp.on_attach'
local G = require 'core.global'
local M = {}

-- List of servers where config = {on_attach = on_attach}
local simple_lsp = {
  dockerls = "docker-langserver",
  graphql = "graphql-lsp",
  html = "html-languageserver",
  svelte= "svelteserver",
  vimls = "vim-language-server",
  yamlls = "yaml-language-server",
}

function M.setup()
  -- List of installed LSP servers
  if ex("bash-language-server") == 1 then
    lspconfig.bashls.setup {
      cmd_env = {
        GLOB_PATTERN = "*@(.sh|.zsh|.inc|.bash|.command)"
      },
      filetypes = {
        "sh",
        "zsh"
      },
      on_attach = on_attach
    }
  end

  if ex("css-languageserver") == 1 then
    lspconfig.cssls.setup {
      root_dir = rpattern('.git', '.gitignore', '.git', vim.fn.getcwd()),
      on_attach = on_attach
    }
  end

  if ex("vscode-json-languageserver") == 1 then
    lspconfig.jsonls.setup {
      cmd = {
        "vscode-json-languageserver",
        "--stdio"
      },
      on_attach = on_attach
    }
  end

  if ex(G.sumneko_binary) == 1 then
    lspconfig.sumneko_lua.setup {
      on_attach = on_attach,
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

  if ex("typescript-language-server") == 1 then
    lspconfig.tsserver.setup {
      root_dir = rpattern('tsconfig.json', 'package.json', '.git', vim.fn.getcwd()),
      on_attach = on_attach
    }
  end

  for lsp, executable in pairs(simple_lsp) do
    if ex(executable) == 1 then
      lspconfig[lsp].setup {
        on_attach = on_attach
      }
    end
  end

  if ex("clangd") > 0 then
    lspconfig.clangd.setup {
      cmd = {
      'clangd',
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
      on_attach = on_attach
    }
  end

  if ex("pyls") > 0 then
    lspconfig.pyls.setup {
      jedi_completion = {enabled = true},
      jedi_hover = {enabled = true},
      jedi_references = {enabled = true},
      jedi_signature_help = {enabled = true},
      jedi_symbols = {enabled = true, all_scopes = true},
      yapf = {enabled = false},
      pylint = {enabled = false},
      pyflakes = {enabled = false},
      pycodestyle = {enabled = false},
      pydocstyle = {enabled = false},
      mccabe = {enabled = false},
      preload = {enabled = false},
      rope_completion = {enabled = false},
      on_attach = on_attach,
      root_dir = rpattern('requirements.txt', '.gitignore', '.git', vim.fn.getcwd()),
    }
  end

  if ex("gopls") > 0 then
    lspconfig.gopls.setup {
      on_attach = on_attach
    }
  end

  if ex("rust-analyzer") > 0 then
    lspconfig.rust_analyzer.setup {
      checkOnSave = {
          command = "clippy"
      },
      on_attach = on_attach
    }
  elseif ex("rls") > 0 then
    lspconfig.rls.setup {
      on_attach = on_attach
    }
  end
end

return M
