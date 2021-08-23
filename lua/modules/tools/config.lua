local config = {}

function config.vim_dadbod_ui()
  vim.cmd [[packadd vim-dadbod]]
  vim.g.db_ui_show_help = 0
  vim.g.db_ui_win_position = "left"
  vim.g.db_ui_use_nerd_fonts = 1
  vim.g.db_ui_winwidth = 35
  vim.g.db_ui_save_location = os.getenv "HOME" .. "/.cache/vim/db_ui_queries"
  -- vim.g.dbs = load_dbs()
  local nnoremap = rvim.nnoremap
  nnoremap("<Leader>od", ":DBUIToggle<CR>")
end

function config.bookmarks()
  vim.g.bookmark_no_default_key_mappings = 1
  vim.g.bookmark_sign = ""
  local nnoremap = rvim.nnoremap
  nnoremap("<Leader>me", ":BookmarkToggle<CR>")
  nnoremap("<Leader>mb", ":BookmarkPrev<CR>")
  nnoremap("<Leader>mk", ":BookmarkNext<CR>")
end

return config
