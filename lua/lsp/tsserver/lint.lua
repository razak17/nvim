local M = {}

local linter = './node_modules/.bin/eslint'

local lint = function()
  -- local root_dir = vim.api.nvim_get_var "proj"
  -- vim.cmd "let proj = utils#FindRootDirectory()"

  local get_linter_instance = function()
    -- prioritize local instance over global
    -- local local_instance = root_dir .. "/node_modules/.bin/" .. linter
    -- if vim.fn.executable(local_instance) == 1 then
    --   return local_instance
    -- end
    return linter
  end

  local tsserver_args = {}
  local formattingSupported = false

  local eslint = {
    lintCommand = get_linter_instance() .. " -f unix --stdin --stdin-filename ${INPUT}",
    lintIgnoreExitCode = true,
    lintStdin = true,
    lintFormats = {"%f:%l:%c: %m"},
    lintSource = "eslint",
  }
  table.insert(tsserver_args, eslint)
  -- Only eslint_d supports --fix-to-stdout
  if string.find(get_linter_instance(), "eslint_d") then
    formattingSupported = true
    local eslint_fix = {
      formatCommand = get_linter_instance() .. " --fix-to-stdout --stdin --stdin-filename ${INPUT}",
      formatStdin = true,
    }
    table.insert(tsserver_args, eslint_fix)
  end

  require'lspconfig'.efm.setup {
    init_options = {documentFormatting = formattingSupported, codeAction = false},
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
    lint()
  end
end

return M
