local config = {}

function config.dap() require 'modules.lang.dap' end

function config.nvim_treesitter() require('modules.lang.treesitter') end

function config.nvim_lsp() require('modules.lang.lsp.lspconfig') end

function config.dap_install()
  local dI = require("dap-install")
  dI.setup({installation_path = core.__dap_install_dir})
end

function config.dap_ui() require("dapui").setup() end

return config

