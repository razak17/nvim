return {
  'williamboman/mason.nvim',
  init = function()
    local icons = rvim.ui.icons.ui
    require('mason').setup({
      ui = {
        border = rvim.ui.current.border,
        height = 0.8,
        icons = {
          package_installed = icons.checkmark,
          package_pending = icons.right_arrow,
          package_uninstalled = icons.uninstalled,
        },
      },
    })
    require('mason-lspconfig').setup({ automatic_installation = true })
    map('n', '<leader>lm', '<cmd>Mason<CR>', { desc = 'mason: info' })
  end,
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
    { 'jayp0521/mason-null-ls.nvim', opts = { automatic_installation = true } },
  },
}
