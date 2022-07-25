local M = {}

function M.setup()
  local status_ok, null_ls = rvim.safe_require('null-ls')
  if not status_ok then
    return
  end

  -- set a formatter, this will override the language server formatting capabilities (if it exists)
  local formatters = require('user.lsp.null-ls.formatters')

  formatters.setup({
    {
      exe = 'prettier_d_slim',
      stdin = true,
      -- @usage arguments to pass to the formatter
      -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
      -- args = {},
      -- @usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
      filetypes = {
        'javascript',
        'typescriptreact',
        'javascriptreact',
        'html',
        'json',
        'jsonc',
        'yaml',
        'graphql',
        'markdown',
        'css',
      },
    },
    {
      exe = 'eslint_d',
      stdin = true,
      args = { '--fix' },
      filetypes = {
        'vue',
        'json',
        'jsonc',
        'javascript',
        'javascriptreact',
        'typescriptreact',
        'typescript',
      },
    },
    {
      exe = 'stylua',
      stdin = true,
      filetypes = { 'lua' },
    },
    -- { exe = "yapf", stdin = true, filetypes = { "python" } },
    { exe = 'black', args = { '--fast' }, filetypes = { 'python' } },
    { exe = 'isort', filetypes = { 'python' } },
    { exe = 'shfmt', filetypes = { 'sh' } },
    -- { exe = "gofmt", filetypes = { "go" } },
  })

  -- set additional linters
  local linters = require('user.lsp.null-ls.linters')

  linters.setup({
    {
      exe = 'shellcheck',
      args = { '--severity', 'warning' },
    },
    { exe = 'flake8', filetypes = { 'python' } },
    {
      exe = 'eslint_d',
      filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
    },
    { exe = 'golangci-lint', filetypes = { 'go' } },
  })

  local default_opts = rvim.lsp.get_global_opts()
  local opts = {
    debug = true,
    -- root_dir = require("lspconfig").util.root_pattern("Makefile", ".git", "node_modules"),
    config = {},
  }
  null_ls.setup(vim.tbl_deep_extend('force', default_opts, opts))
end

return M
