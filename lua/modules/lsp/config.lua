local config = {}

function config.nvim_lsp()
  require('modules.lsp.lspconfig')
end

function config.lspinstall()
  require('modules.lsp.lspinstall')
end

return config
