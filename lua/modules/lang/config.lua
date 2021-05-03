local config = {}

function config.nvim_treesitter()
  require('modules.lang.ts').setup()
end

function config.nvim_lsp()
  require('modules.lang.lsp.lspconfig')
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

function config.dap()
  require 'modules.lang.dap'
end

function config.lsp_saga()
  local opts = {
    error_sign = '',
    warn_sign = '',
    hint_sign = '',
    infor_sign = '',
    dianostic_header_icon = '   ',
    code_action_icon = '💡',
    rename_prompt_prefix = '➤',
    finder_definition_icon = '  ',
    finder_reference_icon = '  ',
    definition_preview_icon = '  ',
    finder_action_keys = {
      open = 'o',
      vsplit = 's',
      split = 'i',
      quit = 'x',
      scroll_down = '<C-f>',
      scroll_up = '<C-b>'
    }
  }
  return opts
end

return config
