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
      exe = "prettier_d_slim",
      stdin = true,
      -- @usage arguments to pass to the formatter
      -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
      args = {
        "--no-semi",
        "--tab-width=2",
        "--single-quote",
        "--print-width=80",
        "--jsx-single-quote",
        "--bracket-same-line",
        "--arrow-parens=avoid",
        "--trailing-comma=all",
      },
      -- @usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "html",
        "json",
        "yaml",
        "graphql",
        "markdown",
        "css",
      },
    },
    {
      exe = "eslint_d",
      stdin = true,
      args = { "--fix" },
      filetypes = { "vue" },
    },
    {
      exe = "stylua",
      stdin = true,
      filetypes = { "lua" },
    },
    -- { exe = "yapf", stdin = true, filetypes = { "python" } },
    { exe = "black", args = { "--fast" }, filetypes = { "python" } },
    { exe = "isort", filetypes = { "python" } },
    { exe = "shfmt", filetypes = { "sh" } },
  }

  -- set additional linters
  local linters = require "user.lsp.null-ls.linters"

  linters.setup {
    {
      exe = "shellcheck",
      args = { "--severity", "warning" },
    },
    { exe = "flake8", filetypes = { "python" } },
    {
      exe = "eslint_d",
      filetypes = { "javascript", "javascriptreact", "typescriptreact", "typescript" },
    },
  }

  local default_opts = require("user.lsp").get_global_opts()
  null_ls.setup(vim.tbl_deep_extend("force", default_opts, rvim.lsp.null_ls.setup))
end

return M
