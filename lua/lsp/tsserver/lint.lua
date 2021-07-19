local M = {}

local ts_lint = function()
  local eslint = {
    lintCommand = "eslint" .. "-f visualstudio --stdin --stdin-filename ${INPUT}",
    lintStdin = true,
    lintFormats = {"%f(%l,%c): %tarning %m", "%f(%l,%c): %rror %m"},
    lintSource = "eslint",
    lintIgnoreExitCode = true,
    formatCommand = "eslint" .. " --fix-to-stdout --stdin  --stdin-filename=${INPUT}",
    formatStdin = true,
  }
  require'lspconfig'.efm.setup {
    init_options = {documentFormatting = true, codeAction = false},
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascriptreact.jsx",
      "typescript",
      "typescriptreact",
      "typescriptreact.tsx",
    },
    settings = {
      rootMarkers = {"package.json", "tsconfig.json", ".gitignore", ".git/"},
      languages = {
        javascript = {eslint},
        javascriptreact = {eslint},
        ["javascriptreact.jsx"] = {eslint},
        typescript = {eslint},
        typescriptreact = {eslint},
        ["typescriptreact.tsx"] = {eslint},
      },
    },
  }
end

M.init = function()
  if core.executable("efm-langserver") then
    ts_lint()
  end
end

return M
