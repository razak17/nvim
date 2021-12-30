local tools = {}

local utils = require "user.utils"

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

tools["diepm/vim-rest-console"] = {
  event = "VimEnter",
  disable = not rvim.plugin.restconsole.active,
}

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
  event = { "BufRead" },
  config = function()
    vim.g["far#source"] = "rg"
    vim.g["far#enable_undo"] = 1
  end,
  disable = not rvim.plugin.far.active,
}

tools["Tastyep/structlog.nvim"] = {
  commit = rvim.plugin.commits.structlog,
}

return tools
