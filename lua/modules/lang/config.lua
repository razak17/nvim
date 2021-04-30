local config = {}

function config.nvim_treesitter()
  require('modules.lang.ts').setup()
end

function config.nvim_lsp()
  require('modules.lang.lsp.lspconfig')
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
    use_saga_diagnostic_sign = true,
    dianostic_header_icon = '   ',
    code_action_icon = '💡',
    rename_prompt_prefix = '➤',
    finder_definition_icon = '  ',
    finder_reference_icon = '  ',
    definition_preview_icon = '  ',
    max_preview_lines = 10,
    code_action_prompt = {
      enable = true,
      sign = true,
      sign_priority = 20,
      virtual_text = true
    },
    code_action_keys = {quit = 'q', exec = '<CR>'},
    rename_action_keys = {quit = '<C-c>', exec = '<CR>'},
    finder_action_keys = {
      open = 'o',
      vsplit = 's',
      split = 'i',
      quit = 'x',
      scroll_down = '<C-n>',
      scroll_up = '<C-b>'
    },
    -- "single" "double" "round" "plus"
    border_style = "single"
  }
  return opts
end

return config

