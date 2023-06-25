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
      local null_ls = require('null-ls')
      require('mason-null-ls').setup({
        automatic_setup = true,
        ensure_installed = { 'goimports', 'golangci_lint', 'stylua', 'prettierd', 'zsh', 'flake8', 'black' },
        automatic_installation = false,
        handlers = {
          eslint = function()
            null_ls.register(null_ls.builtins.diagnostics.eslint.with({ extra_filetypes = { 'svelte' } }))
          end,
          prettier = function() end,
        },
      })
      null_ls.setup({ debug = rvim.debug.enable })
    end,
  },
}
