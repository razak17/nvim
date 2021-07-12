local config = {}

function config.dap() require 'debug.config' end

function config.nvim_treesitter() require('modules.lang.treesitter') end

function config.nvim_lsp() require('modules.lang.lsp.lspconfig') end

function config.dap_install()
  local dI = require("dap-install")
  dI.setup({installation_path = core.__dap_install_dir})
end

function config.dap_ui()
  require("dapui").setup({
    mappings = {expand = "<CR>", open = "o", remove = "d"},
    sidebar = {
      open_on_start = true,
      elements = {"scopes", "breakpoints", "stacks", "watches"},
      width = 50,
      position = "left",
    },
    tray = {
      open_on_start = false,
      elements = {"repl"},
      height = 10,
      position = "bottom",
    },
    floating = {max_height = 0.4, max_width = 0.4},
  })
end

return config

