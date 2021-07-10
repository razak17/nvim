local config = {}

function config.dap() require 'modules.lang.dap' end

function config.nvim_treesitter() require('modules.lang.ts') end

function config.nvim_lsp() require('modules.lang.lsp.lspconfig') end

function config.dapinstall()
  vim.cmd [[packadd DAPInstall.nvim]]
  local dI = require("dap-install")
  dI.setup({installation_path = core.__dapinstall_dir})
  dI.config("python_dbg", {})
end

function config.dap_ui()
  vim.cmd [[packadd nvim-dap]]
  require("dapui").setup({
    mappings = {expand = "<CR>", open = "o", remove = "d"},
  })
end

return config
