local config = {}

function config.nvim_treesitter()
  require('modules.lang.ts')
end

function config.nvim_lsp()
  require('modules.lang.lsp.lspconfig')
end

function config.dap()
  require 'modules.lang.dap'
end

function config.dap_ui()
  require("dapui").setup({
    mappings = {expand = "<CR>", open = "o", remove = "d"}
  })
end

return config
