local vim = vim
local g = vim.g
local cmd = vim.cmd
local config = {}

function config.bg()
  g.nvcode_termcolors=256
  vim.cmd [[ colo onedark ]]

  cmd('autocmd ColorScheme * highlight clear SignColumn')
  cmd('autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE')

  cmd('hi LineNr ctermbg=NONE guibg=NONE ')
  cmd('hi Comment cterm=italic')

  g.onedark_hide_endofbuffer=1
  g.onedark_terminal_italics=1
  g.onedark_termcolors=256
end

function config.bufferline()
  require'bufferline'.setup {
    show_buffer_close_icons = false,
    close_icon = ' ',
    -- modified_icon = "",
    modified_icon = '✥',
    tab_size = 0,
    left_trunc_marker = '',
    right_trunc_marker = '',
    max_name_length = 18,
    max_prefix_length = 15,
    enforce_regular_tabs = false,
    always_show_bufferline = false,
    diagnostics =  "nvim_lsp",
    separator_style = { ' ', ' ' },
    diagnostics_indicator = function(count, level)
      return ''
    end,
    filter = function(buf_num)
      if not vim.t.is_help_tab then return nil end
      return vim.api.nvim_buf_get_option(buf_num, "buftype") == "help"
    end
  }
end

function config.hijackc()
  cmd("highlight! LSPCurlyUnderline gui=undercurl")
  cmd("highlight! LSPUnderline gui=underline")
  cmd("highlight! LspDiagnosticsUnderlineHint gui=undercurl")
  cmd("highlight! LspDiagnosticsUnderlineInformation gui=undercurl")
  cmd("highlight! LspDiagnosticsUnderlineWarning gui=undercurl guisp=darkyellow")
  cmd("highlight! LspDiagnosticsUnderlineError gui=undercurl guisp=red")
  cmd("highlight! LspDiagnosticsSignHint guifg=yellow")
  cmd("highlight! LspDiagnosticsSignInformation guifg=lightblue")
  cmd("highlight! LspDiagnosticsSignWarning guifg=darkyellow")
  cmd("highlight! LspDiagnosticsSignError guifg=red")
end

return config
