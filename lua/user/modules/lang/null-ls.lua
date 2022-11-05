return function()
  local null_ls = require('null-ls')
  local builtins = null_ls.builtins
  local diagnostics = builtins.diagnostics
  local formatting = builtins.formatting
  null_ls.setup({
    debug = true,
    sources = {
      diagnostics.zsh,
      diagnostics.flake8,
      diagnostics.eslint_d.with({
        condition = function()
          return rvim.executable('eslint_d')
            and not vim.tbl_isempty(vim.fs.find({ '.eslintrc.json', '.eslintrc.js', '.eslintrc' }, {
              path = vim.fn.expand('%:p'),
              upward = true,
            }))
        end,
      }),
      diagnostics.golangci_lint,
      diagnostics.shellcheck.with({
        condition = function()
          return rvim.executable('stylua')
            and not vim.tbl_isempty(vim.fs.find({ '.stylua.toml', 'stylua.toml' }, {
              path = vim.fn.expand('%:p'),
              upward = true,
            }))
        end,
        extra_args = { '--severity', 'warning' },
      }),
      formatting.black.with({ extra_args = { '--fast' } }),
      formatting.prettierd,
      formatting.isort,
      formatting.shfmt,
      formatting.stylua.with({ condition = function() return rvim.executable('stylua') end }),
      formatting.goimports,
      -- formatting.pg_format,
    },
  })
  rvim.augroup('NullLsConfig', {
    {
      event = { 'Filetype' },
      pattern = { 'null-ls-info' },
      command = function() vim.api.nvim_win_set_config(0, { border = rvim.style.border.current }) end,
    },
  })
end
