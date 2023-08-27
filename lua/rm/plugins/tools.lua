local border = rvim.ui.current.border

return {
  {
    'jose-elias-alvarez/null-ls.nvim',
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
        ensure_installed = {
          'goimports',
          'golangci_lint',
          'stylua',
          'prettierd',
          'zsh',
          'flake8',
          'black',
        },
        automatic_installation = false,
        handlers = {
          black = function()
            null_ls.register(null_ls.builtins.formatting.black.with({ extra_args = { '--fast' } }))
          end,
          -- eslint_d = function()
          --   null_ls.register(
          --     null_ls.builtins.diagnostics.eslint_d.with({ filetypes = { 'svelte' } })
          --   )
          -- end,
          prettier = function() end,
          eslint_d = function() end,
          prettierd = function()
            null_ls.register(null_ls.builtins.formatting.prettierd.with({
              filetypes = {
                'javascript',
                'typescript',
                'typescriptreact',
                'json',
                'yaml',
                'markdown',
                'svelte',
              },
            }))
          end,
          shellcheck = function()
            null_ls.register(null_ls.builtins.diagnostics.shellcheck.with({
              extra_args = { '--severity', 'warning' },
            }))
          end,
        },
      })
      null_ls.setup({ debug = rvim.debug.enable })
    end,
  },
}
