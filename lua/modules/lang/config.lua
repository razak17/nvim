local config = {}

function config.treesitter()
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

function config.lsp_saga()
  local opts = {
    error_sign = '',
    warn_sign = '',
    hint_sign = '',
    infor_sign = '',
    code_action_icon = '💡'
  }
  return opts
end

return config
