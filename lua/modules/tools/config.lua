local config = {}

function config.fterm()
  require("FTerm").setup()
end

function config.vim_dadbod_ui()
  vim.cmd [[packadd vim-dadbod]]
  vim.g.db_ui_show_help = 0
  vim.g.db_ui_win_position = "left"
  vim.g.db_ui_use_nerd_fonts = 1
  vim.g.db_ui_winwidth = 35
  vim.g.db_ui_save_location = os.getenv "HOME" .. "/.cache/vim/db_ui_queries"
  -- vim.g.dbs = load_dbs()
end

function config.bookmarks()
  vim.g.bookmark_no_default_key_mappings = 1
  vim.g.bookmark_sign = ""
end

return config
