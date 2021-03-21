local M = {}

-- lua
local luaFormat = {
    formatCommand = "lua-format -i --no-keep-simple-function-one-line --column-limit=80",
    formatStdin = true
}

-- python
local isort = {formatCommand = "isort --quiet -", formatStdin = true}
local yapf = {formatCommand = "yapf --quiet", formatStdin = true}

-- JavaScript/React/TypeScript
local prettier = {
    formatCommand = "prettier --stdin-filepath ${INPUT}",
    formatStdin = true
}
local prettier_yaml = {
    formatCommand = "prettier --stdin-filepath ${INPUT}",
    formatStdin = true
}
local eslint = {
    lintCommand = "./node_modules/.bin/eslint -f unix --stdin --stdin-filename ${INPUT}",
    lintIgnoreExitCode = true,
    lintStdin = true,
    lintFormats = {"%f:%l:%c: %m"},
    formatCommand = "./node_modules/.bin/eslint --fix-to-stdout --stdin --stdin-filename=${INPUT}",
    formatStdin = true
}

local shellcheck = {
    LintCommand = 'shellcheck -f gcc -x',
    lintFormats = {
        '%f:%l:%c: %trror: %m', '%f:%l:%c: %tarning: %m', '%f:%l:%c: %tote: %m'
    }
}

local shfmt = {formatCommand = 'shfmt -ci -s -bn', formatStdin = true}

function M.setup(enhance_attach)
    require'lspconfig'.efm.setup {
        on_attach = enhance_attach,
        root_dir = require'lspconfig.util'.root_pattern(vim.fn.getcwd()),
        init_options = {documentFormatting = true, codeAction = false},
        filetypes = {
            "lua", "javascript", "javascriptreact", "typescript",
            "typescriptreact", "python", "html", "css", "json", "yaml", "sh"
        },
        settings = {
            rootMarkers = {
                "package.json", "tsconfig.json", "requirements.txt",
                ".gitignore", ".git/"
            },
            languages = {
                lua = {luaFormat},
                python = {yapf, isort},
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
