local config = {}

function config.nvim_lsp()
  require('modules.lsp.lspconfig')
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
    code_action_keys = {quit = 'q', exec = '<CR>'},
    max_preview_lines = 10,
    finder_action_keys = {
      open = 'o',
      vsplit = 's',
      split = 'i',
      quit = 'x',
      scroll_down = '<C-n>',
      scroll_up = '<C-b>'
    },
    -- "single" "double" "round" "plus"
    border_style = "single",
    rename_action_keys = {quit = '<C-c>', exec = '<CR>'}
  }
  return opts
end

return config
