local config = {}

function config.treesitter()
  require('modules.lang.ts').setup()
end

function config.nvim_lsp()
  require('modules.lang.lsp.lspconfig')
end

function config.dap()
  require 'modules.lang.dap'
end

function config.symbols()
  require("symbols-outline").setup {
    highlight_hovered_item = true,
    show_guides = true
  }
end

function config.trouble()
  require("trouble").setup {
    height = 12,
    use_lsp_diagnostic_signs = true,
    action_keys = {toggle_fold = "ze"}
  }
end

function config.dap_ui()
  require("dapui").setup({
    mappings = {expand = "<CR>", open = "o", remove = "d"},
    sidebar = {
      elements = {"scopes", "stacks", "watches"},
      width = 60,
      position = "left"
    },
    tray = {elements = {"repl"}, height = 10, position = "bottom"}
  })
end

function config.lsp_saga()
  local opts = {
    error_sign = '',
    warn_sign = '',
    hint_sign = '',
    infor_sign = '',
    code_action_icon = '💡',
    finder_action_keys = {quit = 'x'}
  }
  return opts
end

return config
