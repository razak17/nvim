local settings = {
  show_buffer_close_icons = false,
  close_icon = ' ',
  modified_icon = "",
  tab_size = 0,
  left_trunc_marker = '',
  right_trunc_marker = '',
  max_name_length = 18,
  max_prefix_length = 15,
  enforce_regular_tabs = false,
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

require'bufferline'.setup{
  options = settings,
}


