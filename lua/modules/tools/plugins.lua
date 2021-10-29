local tools = {}

local utils = require "utils"

tools["tpope/vim-fugitive"] = {
  event = "VimEnter",
  disable = not rvim.plugin.fugitive.active,
}

tools["sindrets/diffview.nvim"] = {
  event = "BufReadPre",
  config = utils.load_conf("tools", "diff_view"),
  disable = not rvim.plugin.diffview.active,
}

tools["mbbill/undotree"] = {
  cmd = "UndotreeToggle",
  disable = not rvim.plugin.undotree.active,
}

tools["ahmedkhalf/project.nvim"] = {
  config = utils.load_conf("tools", "project"),
  disable = not rvim.plugin.project.active,
}

tools["npxbr/glow.nvim"] = {
  run = ":GlowInstall",
  branch = "main",
  disable = not rvim.plugin.glow.active,
}

tools["kkoomen/vim-doge"] = {
  run = ":call doge#install()",
  config = function()
    vim.g.doge_mapping = "<Leader>vD"
  end,
  disable = not rvim.plugin.doge.active,
}

tools["numToStr/FTerm.nvim"] = {
  event = { "BufWinEnter" },
  config = utils.load_conf("tools", "fterm"),
  disable = not rvim.plugin.fterm.active,
}

tools["MattesGroeger/vim-bookmarks"] = {
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.g.bookmark_no_default_key_mappings = 1
    vim.g.bookmark_sign = ""
  end,
  disable = not rvim.plugin.bookmarks.active,
}

tools["diepm/vim-rest-console"] = { event = "VimEnter", disable = not rvim.plugin.restconsole.active }

tools["iamcco/markdown-preview.nvim"] = {
  config = function()
    vim.g.mkdp_auto_start = 0
  end,
  run = "cd app && yarn install",
  cmd = "MarkdownPreview",
  ft = "markdown",
  disable = not rvim.plugin.markdown_preview.active,
}

tools["brooth/far.vim"] = {
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.g["far#source"] = "rg"
    vim.g["far#enable_undo"] = 1
  end,
  disable = not rvim.plugin.far.active,
}

tools["kristijanhusak/vim-dadbod-ui"] = {
  cmd = { "DBUIToggle", "DBUIAddConnection", "DBUI", "DBUIFindBuffer", "DBUIRenameBuffer" },
  config = function()
    vim.cmd [[packadd vim-dadbod]]
    vim.g.db_ui_show_help = 0
    vim.g.db_ui_win_position = "left"
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_winwidth = 35
    vim.g.db_ui_save_location = os.getenv "HOME" .. "/.cache/vim/db_ui_queries"
  end,
  requires = {
    { "tpope/vim-dadbod", opt = true },
    { "kristijanhusak/vim-dadbod-completion", opt = true },
  },
  disable = not rvim.plugin.dadbod.active,
}

return tools
