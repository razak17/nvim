local formatters = require 'modules.lsp.efm.formatters'
local linters = require 'modules.lsp.efm.linters'
local M = {}

local luaFormat = formatters.luaFormat

local eslint = linters.eslint
local prettier = formatters.prettier
local prettier_yaml = formatters.prettier_yaml

local yapf = formatters.yapf
local black = formatters.black
local flake8 = linters.flake8

local shellcheck = linters.shellcheck
local shfmt = formatters.shfmt

function M.setup()
  require'lspconfig'.efm.setup {
    handlers = require'modules.lsp.lspconfig.utils'.diagnostics,
    capabilities = require'modules.lsp.servers'.capabilities,
    on_attach = require'modules.lsp.servers'.enhance_attach,
    root_dir = require'lspconfig.util'.root_pattern(vim.fn.getcwd()),
    init_options = {documentFormatting = true, codeAction = false},
    filetypes = {
      "lua",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "python",
      "html",
      "css",
      "json",
      "yaml",
      "sh"
    },
    settings = {
      rootMarkers = {
        "package.json",
        "tsconfig.json",
        "requirements.txt",
        ".gitignore",
        ".git/"
      },
      languages = {
        lua = {luaFormat},
        python = {yapf, black, flake8},
        javascript = {prettier, eslint},
        javascriptreact = {prettier, eslint},
        typescript = {prettier, eslint},
        typescriptreact = {prettier, eslint},
        html = {prettier},
        css = {prettier},
        json = {prettier},
        yaml = {prettier_yaml},
        sh = {shellcheck, shfmt}
      }
    }
  }
end

return M

