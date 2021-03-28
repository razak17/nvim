local config = {}

function config.nvim_lsp()
  require('modules.completion.lsp')
end

function config.nvim_compe()
  require('compe').setup {
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 1,
    preselect = "enable",
    throttle_time = 80,
    source_timeout = 200,
    incomplete_delay = 400,
    documentation = true,
    allow_prefix_unmatch = false,
    source = {
      nvim_lsp = true,
      buffer = true,
      calc = true,
      vsnip = true,
      path = true,
      treesitter = true
    }
  }
end

function config.saga()
  local opts = {
    error_sign = '',
    warn_sign = '',
    hint_sign = '',
    infor_sign = '',
    use_saga_diagnostic_sign = true,
    dianostic_header_icon = '   ',
    code_action_icon = ' ',
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
    -- 1: thin border | 2: rounded border | 3: thick border | 4: ascii border
    border_style = 1,
    rename_action_keys = {quit = '<C-c>', exec = '<CR>'}
  }
  return opts
end

function config.vim_vsnip()
  local G = require 'core.global'
  vim.g["vsnip_snippet_dir"] = G.vim_path .. "snippets"
end

function config.emmet()
  vim.g.user_emmet_leader_key = '<C-y>'
  vim.g.user_emmet_complete_tag = 0
  vim.g.user_emmet_install_global = 0
  vim.g.user_emmet_mode = 'i'
  vim.cmd('autocmd FileType html,css EmmetInstall')
end

function config.telescope_nvim()
  require('modules.completion.telescope')
end

return config

