return function()
  if not rvim.plugin_installed('null-ls.nvim') then return end
  local null_ls = require('null-ls')
  local builtins = null_ls.builtins
  local diagnostics = builtins.diagnostics
  local formatting = builtins.formatting
  local code_actions = builtins.codeactions
  null_ls.setup({
    sources = {
      -- codeactions
      code_actions.shellcheck,
      code_actions.gitsigns,
      null_ls.builtins.code_actions.eslint_d,
      -- linters
      diagnostics.zsh,
      diagnostics.flake8,
      diagnostics.eslint_d:with({
        filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
      }),
      diagnostics.shellcheck.with({ extra_args = { '--severity', 'warning' } }),
      -- formatters
      formatting.black.with({ extra_args = { '--fast' } }),
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
