return function()
  local null_ls = require('null-ls')
  local diagnostics = null_ls.builtins.diagnostics
  local formatting = null_ls.builtins.formatting
  null_ls.setup({
    debounce = 150,
    sources = {
      diagnostics.zsh,
      diagnostics.flake8,
      diagnostics.eslint_d:with({
        filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
      }),
      diagnostics.golangci_lint,
      diagnostics.shellcheck.with({ extra_args = { '--severity', 'warning' } }),
      -- formatters
      formatting.black.with({ extra_args = { '--fast' } }),
      -- formatting.eslint_d.with({
      --   extra_args = { '--fix' },
      --   filetypes = {
      --     'vue',
      --     'json',
      --     'jsonc',
      --     'javascript',
      --     'javascriptreact',
      --     'typescriptreact',
      --     'typescript',
      --   },
      -- }),
      formatting.prettier_d_slim.with({
        filetypes = {
          'html',
          'yaml',
          'graphql',
          'markdown',
          'css',
          'json',
          'jsonc',
          'javascript',
          'javascriptreact',
          'typescriptreact',
          'typescript',
        },
      }),
      formatting.isort,
      formatting.shfmt,
      formatting.stylua.with({ condition = function() return rvim.executable('stylua') end }),
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
