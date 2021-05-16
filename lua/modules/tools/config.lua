local config = {}

function config.floaterm()
  vim.g.floaterm_keymap_kill = '<F6>'
  vim.g.floaterm_keymap_new = '<F7>'
  vim.g.floaterm_keymap_prev = '<F8>'
  vim.g.floaterm_keymap_next = '<F9>'
  vim.g.floaterm_keymap_toggle = '<F12>'

  vim.g.floaterm_gitcommit = 'floaterm'
  vim.g.floaterm_autoinsert = 1
  vim.g.floaterm_width = 0.8
  vim.g.floaterm_height = 0.9
  vim.g.floaterm_wintitle = ''
  vim.g.floaterm_autoclose = 1
end

function config.vim_dadbod_ui()
  if packer_plugins['vim-dadbod'] and not packer_plugins['vim-dadbod'].loaded then
    vim.cmd [[packadd vim-dadbod]]
  end
  vim.g.db_ui_show_help = 0
  vim.g.db_ui_win_position = 'left'
  vim.g.db_ui_use_nerd_fonts = 1
  vim.g.db_ui_winwidth = 35
  vim.g.db_ui_save_location = os.getenv("HOME") .. '/.cache/vim/db_ui_queries'
  -- vim.g.dbs = load_dbs()
end

function config.bookmarks()
  vim.g.bookmark_no_default_key_mappings = 1
  vim.g.bookmark_sign = ''
end

return config
