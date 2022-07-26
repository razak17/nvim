return function()
  local null_ls = require('null-ls')
  null_ls.setup({
    debounce = 150,
    sources = {
      null_ls.builtins.diagnostics.zsh,
      null_ls.builtins.diagnostics.flake8,
      null_ls.builtins.diagnostics.eslint_d:with({
        filetypes = {
          'javascript',
          'javascriptreact',
          'typescript',
          'typescriptreact',
          'vue',
        },
      }),
      null_ls.builtins.diagnostics.golangci_lint,
      null_ls.builtins.diagnostics.shellcheck.with({
        extra_args = { '--severity', 'warning' },
      }),
      -- formatters
      null_ls.builtins.formatting.black.with({ extra_args = { '--fast' } }),
      null_ls.builtins.formatting.eslint_d.with({
        extra_args = { '--fix' },
        filetypes = {
          'vue',
          'json',
          'jsonc',
          'javascript',
          'javascriptreact',
          'typescriptreact',
          'typescript',
        },
      }),
      null_ls.builtins.formatting.prettier_d_slim.with({
        filetypes = {
          'html',
          'yaml',
          'graphql',
          'markdown',
          'css',
        },
      }),
      null_ls.builtins.formatting.isort,
      null_ls.builtins.formatting.shfmt,
      null_ls.builtins.formatting.stylua.with({
        condition = function() return rvim.executable('stylua') end,
      }),
    },
  })
  rvim.augroup('NullLsConfig', {
    {
      event = { 'Filetype' },
      pattern = { 'null-ls-info' },
      command = function() vim.api.nvim_win_set_config(0, { border = rvim.style.border.current }) end,
    },
  })

  rvim.nnoremap('<leader>ln', ':NullLsInfo<CR>', 'null-ls: info')
end
