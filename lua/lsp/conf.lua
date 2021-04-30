local vim = vim
local lspconf = require('lspconfig')
local on_attach = require('lsp/on_attach')
local G = require('global')
local M = {}

function M.setup()
  if vim.fn.executable('ccls') > 0 then
      lspconf.ccls.setup {
          on_attach = on_attach
      }
  elseif vim.fn.executable('clangd') > 0 then
      lspconf.clangd.setup {
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

  if vim.fn.executable(G.python3 .. 'bin' .. G.path_sep ..'pyls') then
      lspconf.pyls.setup {
          cmd = {G.python3 .. 'bin' .. G.path_sep ..'pyls'},
          settings = {
              pyls = {
                  executable = G.python3 .. 'bin' .. G.path_sep ..'pyls'
              }
          },
          on_attach = on_attach,
          root_dir = function(fname)
              return lspconf.util.root_pattern(
                  'pyproject.toml',
                  'setup.py',
                  'setup.cfg',
                  'requirements.txt',
                  'mypy.ini',
                  '.pylintrc',
                  '.flake8rc',
                  '.gitignore'
              )(fname)
              or lspconf.util.find_git_ancestor(fname) or vim.loop.os_homedir()
          end
      }
  end

  if vim.fn.executable('gopls') > 0 then
      lspconf.gopls.setup {
          on_attach = on_attach
      }
  end

  if vim.fn.executable('rust_analyzer') > 0 then
      lspconf.rust_analyzer.setup {
          on_attach = on_attach
      }
  elseif vim.fn.executable('rls') > 0 then
      lspconf.rls.setup {
          on_attach = on_attach
      }
  end
end

return M
