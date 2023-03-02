return {
  'jose-elias-alvarez/null-ls.nvim',
  event = 'VeryLazy',
  keys = {
    {
      '<leader>ln',
      function() require('null-ls.info').show_window({ border = rvim.ui.current.border }) end,
      desc = 'null-ls: info',
    },
  },
  init = function()
    rvim.highlight.plugin('null-ls', {
      { NullLsInfoBorder = { link = 'FloatBorder' } },
    })
  end,
  config = function()
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
              and not vim.tbl_isempty(
                vim.fs.find({ '.eslintrc.json', '.eslintrc.js', '.eslintrc' }, {
                  path = vim.fn.expand('%:p'),
                  upward = true,
                })
              )
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
  end,
}
