local M = {
  'jose-elias-alvarez/null-ls.nvim',
  event = 'VeryLazy',
  dependencies = {
    {
      'jayp0521/mason-null-ls.nvim',
      config = function()
        require('mason-null-ls').setup({
          automatic_installation = true,
        })
      end,
    },
  },
}

function M.init() rvim.nnoremap('<leader>ln', '<cmd>NullLsInfo<CR>', 'null-ls: info') end

function M.config()
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
      formatting.prettier,
      formatting.isort,
      formatting.shfmt,
      formatting.stylua.with({ condition = function() return rvim.executable('stylua') end }),
      formatting.goimports,
    },
    on_attach = function(client, bufnr)
      -- lsp-format-modifications.nvim
      local lfm_ok, lsp_format_modifications = rvim.safe_require('lsp-format-modifications')
      if lfm_ok and vim.tbl_contains({ 'clangd', 'tsserver', 'null-ls' }, client.name) then
        lsp_format_modifications.attach(client, bufnr, { format_on_save = false })
      end
    end,
  })
  rvim.augroup('NullLsConfig', {
    {
      event = { 'Filetype' },
      pattern = { 'null-ls-info' },
      command = function() vim.api.nvim_win_set_config(0, { border = rvim.style.border.current }) end,
    },
  })
end

return M
