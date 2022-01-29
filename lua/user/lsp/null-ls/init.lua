local M = {}

local Log = require "user.core.log"

function M:setup()
  local status_ok, null_ls = rvim.safe_require "null-ls"
  if not status_ok then
    Log:error "Missing null-ls dependency"
    return
  end

  -- set a formatter, this will override the language server formatting capabilities (if it exists)
  local formatters = require "user.lsp.null-ls.formatters"

  formatters.setup {
    {
      exe = "prettier",
      stdin = true,
      -- @usage arguments to pass to the formatter
      -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
      -- "arrowParens": "always",
      -- "bracketSpacing": true,
      -- "endOfLine": "lf",
      -- "htmlWhitespaceSensitivity": "css",
      -- "insertPragma": false,
      -- "jsxBracketSameLine": false,
      -- "jsxSingleQuote": false,
      -- "printWidth": 80,
      -- "proseWrap": "preserve",
      -- "quoteProps": "as-needed",
      -- "requirePragma": false,
      -- "semi": true,
      -- "singleQuote": false,
      -- "tabWidth": 2,
      -- "trailingComma": "es5",
      -- "useTabs": false,
      -- "vueIndentScriptAndStyle": false,
      -- "filepath": "/home/razak/docs/index.html",
      -- "parser": "html"
      -- args = {
      --   "--no-semi",
      --   "--single-quote",
      --   "--jsx-single-quote",
      -- },
      -- @usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
      filetypes = { "typescript", "typescriptreact", "javascript" },
      -- filetypes = { "typescript", "typescriptreact", "html", "json", "yaml", "graphql", "markdown" },
    },
    {
      exe = "stylua",
      stdin = true,
      filetypes = { "lua" },
    },
    -- { exe = "yapf", stdin = true, filetypes = { "python" } },
    { exe = "black", args = { "--fast" }, filetypes = { "python" } },
    { exe = "isort", filetypes = { "python" } },
  }

  -- set additional linters
  local linters = require "user.lsp.null-ls.linters"

  linters.setup {
    {
      exe = "shellcheck",
      -- @usage arguments to pass to the formatter
      -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
      args = { "--severity", "warning" },
    },
    { exe = "flake8", filetypes = { "python" } },
    { exe = "eslint", filetypes = { "javascript" } },
    -- {
    --   exe = "codespell",
    --   stdin = true,
    --   -- @usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
    --   filetypes = { "javascript", "python" },
    -- },
  }

  local default_opts = require("user.lsp").get_global_opts()
  null_ls.setup(vim.tbl_deep_extend("force", default_opts, rvim.lsp.null_ls.setup))
end

return M
