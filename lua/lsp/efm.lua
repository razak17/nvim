local formatters = {
  luaFormat = {
    formatCommand = "lua-format -i -c" .. vim.fn.stdpath('config') .. "/.lua-format",
    formatStdin = true,
  },
  isort = {formatCommand = "isort --quiet -", formatStdin = true},
  yapf = {formatCommand = "yapf --quiet", formatStdin = true},
  black = {formatCommand = "black --quiet -", formatStdin = true},
  prettier = {formatCommand = "prettier --stdin-filepath ${INPUT}", formatStdin = true},
  prettier_yaml = {formatCommand = "prettier --stdin-filepath ${INPUT}", formatStdin = true},
  shfmt = {formatCommand = 'shfmt -ci -s -bn', formatStdin = true},
}

local linters = {
  eslint = {
    -- lintCommand = "./node_modules/.bin/eslint -f unix --stdin --stdin-filename ${INPUT}",
    -- lintIgnoreExitCode = true,
    -- lintStdin = true,
    -- lintFormats = {"%f:%l:%c: %m"},
    -- formatCommand = "./node_modules/.bin/eslint --fix-to-stdout --stdin --stdin-filename=${INPUT}",
    -- formatStdin = true,
    lintCommand = "./node_modules/.bin/eslint" ..
      "-f visualstudio --stdin --stdin-filename ${INPUT}",
    lintStdin = true,
    lintFormats = {"%f(%l,%c): %tarning %m", "%f(%l,%c): %rror %m"},
    lintSource = "./node_modules/.bin/eslint",
    lintIgnoreExitCode = true,
    formatCommand = "./node_modules/.bin/eslint" ..
      " --fix-to-stdout --stdin  --stdin-filename=${INPUT}",
    formatStdin = true,
  },
  flake8 = {
    LintCommand = "flake8 --stdin-display-name ${INPUT} -",
    lintStdin = true,
    lintFormats = {"%f:%l:%c: %m"},
  },
  shellcheck = {
    LintCommand = 'shellcheck -f gcc -x',
    lintFormats = {'%f:%l:%c: %trror: %m', '%f:%l:%c: %tarning: %m', '%f:%l:%c: %tote: %m'},
  },
}

local luaFormat = formatters.luaFormat

local eslint = linters.eslint
local prettier = formatters.prettier
local prettier_yaml = formatters.prettier_yaml

local isort = formatters.isort
local black = formatters.black
local yapf = formatters.yapf
local flake8 = linters.flake8

local shellcheck = linters.shellcheck
local shfmt = formatters.shfmt

local M = {}
function M.setup(capabilities)
  require'lspconfig'.efm.setup {
    capabilities = capabilities,
    on_attach = core.lsp.on_attach,
    init_options = {documentFormatting = true, codeAction = false},
    filetypes = {
      "lua",
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
      "python",
      "html",
      "css",
      "json",
      "yaml",
      "sh",
    },
    settings = {
      rootMarkers = {"package.json", "tsconfig.json", "requirements.txt", ".gitignore", ".git/"},
      languages = {
        lua = {luaFormat},
        python = {isort, black, yapf, flake8},
        javascript = {prettier, eslint},
        javascriptreact = {prettier, eslint},
        ["javascriptreact.jsx"] = {prettier, eslint},
        typescript = {prettier, eslint},
        typescriptreact = {prettier, eslint},
        ["typescriptreact.tsx"] = {prettier, eslint},
        html = {prettier},
        css = {prettier},
        json = {prettier},
        yaml = {prettier_yaml},
        sh = {shellcheck, shfmt},
      },
    },
  }
end

return M
