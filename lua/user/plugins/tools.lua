local border = rvim.ui.current.border

return {
  {
    'jose-elias-alvarez/null-ls.nvim',
    enabled = rvim.lsp.enable,
    -- event = { 'BufReadPre', 'BufNewFile' },
    -- config = function()
    --   local null_ls = require('null-ls')
    --   local builtins = null_ls.builtins
    --   local diagnostics = builtins.diagnostics
    --   local formatting = builtins.formatting
    --   null_ls.setup({
    --     debug = true,
    --     sources = {
    --       diagnostics.zsh,
    --       diagnostics.flake8,
    --       diagnostics.eslint_d.with({ filetypes = { 'svelte' } }),
    --       diagnostics.eslint.with({ filetypes = { 'svelte' } }),
    --       diagnostics.golangci_lint,
    --       diagnostics.shellcheck.with({ extra_args = { '--severity', 'warning' } }),
    --       formatting.black.with({ extra_args = { '--fast' } }),
    --       formatting.prettierd,
    --       formatting.isort,
    --       formatting.shfmt,
    --       formatting.stylua,
    --       formatting.goimports,
    --     },
    --   })
    -- end,
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
          eslint_d = function()
            null_ls.register(null_ls.builtins.diagnostics.eslint_d.with({ filetypes = { 'svelte' } }))
          end,
          prettier = function() end,
        },
      })
      null_ls.setup({ debug = rvim.debug.enable })
    end,
  },
}
