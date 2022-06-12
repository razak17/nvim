local M = {}

local Log = require("user.core.log")

function M.setup()
  local status_ok, null_ls = rvim.safe_require("null-ls")
  if not status_ok then
    Log:error("Missing null-ls dependency")
    return
  end

  -- set a formatter, this will override the language server formatting capabilities (if it exists)
  local formatters = require("user.lsp.null-ls.formatters")

  formatters.setup({
    {
      exe = "prettier_d_slim",
      stdin = true,
      -- @usage arguments to pass to the formatter
      -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
      -- args = {},
      -- @usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
      filetypes = {
        "javascript",
        "typescriptreact",
        "javascriptreact",
        "html",
        "json",
        "jsonc",
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
      filetypes = {
        "vue",
        "json",
        "jsonc",
        "javascript",
        "javascriptreact",
        "typescriptreact",
        "typescript",
      },
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
    -- { exe = "gofmt", filetypes = { "go" } },
  })

  -- set additional linters
  local linters = require("user.lsp.null-ls.linters")

  linters.setup({
    {
      exe = "shellcheck",
      args = { "--severity", "warning" },
    },
    { exe = "flake8", filetypes = { "python" } },
    {
      exe = "eslint_d",
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
    },
  })

  local default_opts = require("user.lsp").get_global_opts()
  null_ls.setup(vim.tbl_deep_extend("force", default_opts, rvim.lsp.null_ls.setup))
end

return M
