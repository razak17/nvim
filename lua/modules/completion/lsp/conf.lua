local vim, fn = vim, vim.fn
local lspconfig = require 'lspconfig'
local on_attach = require 'modules.completion.lsp.on_attach'
local G = require 'core.global'
local M = {}

function _G.reload_lsp()
  vim.lsp.stop_client(vim.lsp.get_active_clients())
  vim.cmd [[edit]]
end

function _G.open_lsp_log()
  local path = vim.lsp.get_log_path()
  vim.cmd("edit " .. path)
end

vim.cmd('command! -nargs=0 LspLog call v:lua.open_lsp_log()')
vim.cmd('command! -nargs=0 LspRestart call v:lua.reload_lsp()')

vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    update_in_insert = true,
    virtual_text = {
      spacing = 4,
    },
    signs = true,
})

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
  if fn.executable("bash-language-server") == 1 then
    lspconfig.bashls.setup {
      cmd_env = {
        GLOB_PATTERN = "*@(.sh|.zsh|.inc|.bash|.command)"
      },
      filetypes = {
        "sh",
        "zsh"
      },
      root_dir = function(fname)
      return lspconfig.util.root_pattern(
        '.git',
        '.gitignore'
      )(fname)
      or lspconfig.util.find_git_ancestor(fname) or vim.loop.os_homedir()
      end,
      on_attach = on_attach
    }
  end

  if fn.executable("css-languageserver") == 1 then
    lspconfig.cssls.setup {
      root_dir = function(fname)
      return lspconfig.util.root_pattern(
        '.git',
        '.gitignore'
      )(fname)
      or lspconfig.util.find_git_ancestor(fname) or vim.loop.os_homedir()
      end,
      on_attach = on_attach
    }
  end

  if fn.executable("vscode-json-languageserver") == 1 then
    lspconfig.jsonls.setup {
      cmd = {
        "vscode-json-languageserver",
        "--stdio"
      },
      on_attach = on_attach
    }
  end

  if fn.executable(G.sumneko_binary) == 1 then
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

  if fn.executable("typescript-language-server") == 1 then
    lspconfig.tsserver.setup {
      root_dir = function(fname)
      return lspconfig.util.root_pattern(
        'tsconfig.json',
        'package.json',
          '.git'
      )(fname)
      or lspconfig.util.find_git_ancestor(fname) or vim.loop.os_homedir()
      end,
      on_attach = on_attach
    }
  end

  for lsp, executable in pairs(simple_lsp) do
    if vim.fn.executable(executable) == 1 then
      lspconfig[lsp].setup {
        on_attach = on_attach
      }
    end
  end

  if vim.fn.executable("clangd") > 0 then
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

  if vim.fn.executable("pyls") > 0 then
    lspconfig.pyls.setup {
      preload = {enabled = true},
      pydocstyle = {
        enabled = true,
        match = '(?!test_).*\\.py',
        matchDir = '[^\\.].*',
      },
      pycodestyle = {
        enabled = true,
        hangClosing = true,
        maxLineLength = 80
      },
      pylint =  { enabled = false },
      mccabe = {enabled = true, threshold = 15},
      rope_completion = {enabled = true},
      pyflakes = {enabled = true},
      yapf = {enabled = true},
      on_attach = on_attach,
      root_dir = function(fname)
      return lspconfig.util.root_pattern(
        'requirements.txt',
        'reqs.txt',
        '.gitignore'
      )(fname)
      or lspconfig.util.find_git_ancestor(fname) or vim.loop.os_homedir()
      end
    }
  end

  if vim.fn.executable("gopls") > 0 then
    lspconfig.gopls.setup {
      on_attach = on_attach
    }
  end

  if vim.fn.executable("rust-analyzer") > 0 then
    lspconfig.rust_analyzer.setup {
      checkOnSave = {
          command = "clippy"
      },
      on_attach = on_attach
    }
  elseif vim.fn.executable("rls") > 0 then
    lspconfig.rls.setup {
      on_attach = on_attach
    }
  end
end

return M
