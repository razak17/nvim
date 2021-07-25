local formatters = {
  prettier = {formatCommand = "prettier --stdin-filepath ${INPUT}", formatStdin = true},
  prettier_yaml = {formatCommand = "prettier --stdin-filepath ${INPUT}", formatStdin = true},
}

local linters = {
  eslint = {
    -- lintCommand = "./node_modules/.bin/eslint -f unix --stdin --stdin-filename ${INPUT}",
    -- lintIgnoreExitCode = true,
    -- lintStdin = true,
    -- lintFormats = {"%f:%l:%c: %m"},
    -- formatCommand = "./node_modules/.bin/eslint --fix-to-stdout --stdin --stdin-filename=${INPUT}",
    -- formatStdin = true,
    lintCommand = "eslint" .. "-f visualstudio --stdin --stdin-filename ${INPUT}",
    lintStdin = true,
    lintFormats = {"%f(%l,%c): %tarning %m", "%f(%l,%c): %rror %m"},
    lintSource = "eslint",
    lintIgnoreExitCode = true,
    formatCommand = "eslint" .. " --fix-to-stdout --stdin  --stdin-filename=${INPUT}",
    formatStdin = true,
  },
}

local eslint = linters.eslint
local prettier = formatters.prettier
local prettier_yaml = formatters.prettier_yaml

local M = {}
function M.setup(capabilities)
  if core.check_lsp_client_active "efm" then
    return
  end
  require'lspconfig'.efm.setup {
    capabilities = capabilities,
    on_attach = core.lsp.on_attach,
    init_options = {documentFormatting = true, codeAction = false},
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
      "html",
      "css",
      "yaml",
    },
    settings = {
      rootMarkers = {"package.json", "tsconfig.json", "requirements.txt", ".gitignore", ".git/"},
      languages = {
        javascript = {prettier, eslint},
        javascriptreact = {prettier, eslint},
        ["javascriptreact.jsx"] = {prettier, eslint},
        typescript = {prettier, eslint},
        typescriptreact = {prettier, eslint},
        ["typescriptreact.tsx"] = {prettier, eslint},
        html = {prettier},
        css = {prettier},
        yaml = {prettier_yaml},
      },
    },
  }
end

return M
