return function()
  if not rvim.plugin_installed('null-ls.nvim') then return end
  local null_ls = require('null-ls')
  local builtins = null_ls.builtins
  local diagnostics = builtins.diagnostics
  local formatting = builtins.formatting
  null_ls.setup({
    sources = {
      -- linters
      diagnostics.zsh,
      diagnostics.flake8,
      diagnostics.eslint_d,
      diagnostics.shellcheck.with({ extra_args = { '--severity', 'warning' } }),
      -- formatters
      formatting.black.with({ extra_args = { '--fast' } }),
      formatting.prettierd,
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
