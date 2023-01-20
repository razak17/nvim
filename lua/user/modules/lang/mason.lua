local M = {
  'williamboman/mason.nvim',
  lazy = false,
  dependencies = { 'williamboman/mason-lspconfig.nvim' },
}

function M.init() rvim.nnoremap('<leader>lm', '<cmd>Mason<CR>', 'mason: info') end

function M.config()
  local style = rvim.style
  local icons = style.icons
  require('mason').setup({
    ui = {
      border = style.border.current,
      top_offset = 5,
      height = vim.o.lines - vim.o.cmdheight - 5 - 8,
      icons = {
        package_installed = icons.misc.checkmark,
        package_pending = icons.misc.right_arrow,
        package_uninstalled = icons.misc.uninstalled,
      },
    },
  })
  require('mason-lspconfig').setup({
    automatic_installation = rvim.lsp.automatic_servers_installation,
  })
end

return M
