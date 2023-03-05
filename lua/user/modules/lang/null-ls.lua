return {
  {
    'jose-elias-alvarez/null-ls.nvim',
    keys = {
      {
        '<leader>ln',
        function() require('null-ls.info').show_window({ border = rvim.ui.current.border }) end,
        desc = 'null-ls: info',
      },
    },
  },

  {
    'jay-babu/mason-null-ls.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mason-null-ls').setup({
        automatic_setup = true,
        automatic_installation = {},
      -- stylua: ignore
        ensure_installed = {
          'goimports', 'golangci_lint', 'stylua', 'prettier', 'zsh',
          'flake8', 'shellcheck', 'black', 'shfmt',
        },
      })
      require('null-ls').setup({
        on_attach = function(client, bufnr)
          local lfm_ok, lsp_format_modifications = rvim.require('lsp-format-modifications')
          if lfm_ok and vim.tbl_contains({ 'clangd', 'tsserver', 'null-ls' }, client.name) then
            lsp_format_modifications.attach(client, bufnr, { format_on_save = false })
          end
        end,
      })
      require('mason-null-ls').setup_handlers()
    end,
  },
}
