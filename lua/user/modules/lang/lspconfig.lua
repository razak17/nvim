return function()
  require("user.lsp").setup()

  -- set a formatter, this will override the language server formatting capabilities (if it exists)
  local formatters = require "user.lsp.null-ls.formatters"

  formatters.setup {
    {
      exe = "prettier",
      -- @usage arguments to pass to the formatter
      -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
      args = { "--no-semi", "--single-quote", "--jsx-single-quote", "--print-with", "100" },
      -- @usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
      filetypes = { "typescript", "typescriptreact", "html", "json", "yaml", "graphql", "markdown" },
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
    {
      exe = "codespell",
      -- @usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
      filetypes = { "javascript", "python" },
    },
  }
end
