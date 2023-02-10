local M = {
  'williamboman/mason.nvim',
  lazy = false,
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
    { 'jayp0521/mason-null-ls.nvim', opts = { automatic_installation = true } },
  },
  init = function() rvim.nnoremap('<leader>lm', '<cmd>Mason<CR>', 'mason: info') end,
}

function M.config()
  local icons = rvim.style.icons
  require('mason').setup({
    ui = {
      border = rvim.style.current.border,
      height = vim.o.lines - vim.o.cmdheight - 8,
      icons = {
        package_installed = icons.misc.checkmark,
        package_pending = icons.misc.right_arrow,
        package_uninstalled = icons.misc.uninstalled,
      },
    },
  })
  require('mason-lspconfig').setup({ automatic_installation = true })
end

return M
