local formatters = require 'modules.completion.lsp.efm.formatters'
local linters = require 'modules.completion.lsp.efm.linters'
local M = {}

local luaFormat = formatters.luaFormat

local eslint = linters.eslint
local prettier = formatters.prettier
local prettier_yaml = formatters.prettier_yaml

local yapf = formatters.yapf
local isort = formatters.isort

local shellcheck = linters.shellcheck
local shfmt = formatters.shfmt

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

