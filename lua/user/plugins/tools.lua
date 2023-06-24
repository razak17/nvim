local border = rvim.ui.current.border

return {
  {
    'razak17/null-ls.nvim',
    enabled = rvim.lsp.enable,
    keys = {
      {
        '<leader>ln',
        function() require('null-ls.info').show_window({ height = 0.7, border = border }) end,
        desc = 'null-ls info',
      },
    },
  },
  {
    'jay-babu/mason-null-ls.nvim',
    enabled = rvim.lsp.enable,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mason-null-ls').setup({
        automatic_setup = true,
        ensure_installed = { 'goimports', 'golangci_lint', 'stylua', 'prettierd', 'zsh', 'flake8', 'black' },
        automatic_installation = false,
        handlers = {
          prettier = function(source_name, methods) end,
        },
      })
      require('null-ls').setup({
        debug = rvim.debug.enable,
        on_attach = function(client, bufnr)
          local lfm_ok, lsp_format_modifications = rvim.pcall(require, 'lsp-format-modifications')
          if lfm_ok and vim.tbl_contains({ 'clangd', 'tsserver', 'null-ls' }, client.name) then
            lsp_format_modifications.attach(client, bufnr, { format_on_save = false })
          end
        end,
      })
    end,
  },
}
