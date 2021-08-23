local tools = {}
local conf = require "modules.tools.config"

local function load_conf(name)
  return require(string.format("modules.tools.%s", name))
end

tools["tpope/vim-fugitive"] = {
  event = "VimEnter",
  config = load_conf "fugitive",
  disable = not rvim.plugin.fugitive.active,
}

tools["sindrets/diffview.nvim"] = {
  event = "BufReadPre",
  config = load_conf "diff_view",
  disable = not rvim.plugin.diffview.active,
}

tools["mbbill/undotree"] = {
  cmd = "UndotreeToggle",
  config = function()
    local nnoremap = rvim.nnoremap
    nnoremap("<Leader>au", ":UndotreeToggle<CR>")
  end,
  disable = not rvim.plugin.undotree.active,
}

tools["ahmedkhalf/project.nvim"] = {
  config = load_conf "project",
  disable = not rvim.plugin.project.active,
}

tools["npxbr/glow.nvim"] = {
  run = ":GlowInstall",
  branch = "main",
  config = function()
    local nnoremap = rvim.nnoremap
    nnoremap("<Leader>og", ":Glow<CR>")
  end,
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
  config = load_conf "fterm",
  disable = not rvim.plugin.fterm.active,
}

tools["MattesGroeger/vim-bookmarks"] = {
  event = { "BufReadPre", "BufNewFile" },
  config = conf.bookmarks,
  disable = not rvim.plugin.bookmarks.active,
}

tools["diepm/vim-rest-console"] = { event = "VimEnter", disable = not rvim.plugin.restconsole.active }

tools["iamcco/markdown-preview.nvim"] = {
  config = function()
    vim.g.mkdp_auto_start = 0
    local nnoremap = rvim.nnoremap
    nnoremap("<Leader>om", ":MarkdownPreview<CR>")
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
    -- Mappings
    local nnoremap = rvim.nnoremap
    nnoremap("<Leader>Ff", ":Farr --source=vimgrep<CR>")
    nnoremap("<Leader>Fd", ":Fardo<CR>")
    nnoremap("<Leader>Fi", ":Farf<CR>")
    nnoremap("<Leader>Fr", ":Farr --source=rgnvim<CR>")
    nnoremap("<Leader>Fz", ":Farundo<CR>")
  end,
  disable = not rvim.plugin.far.active,
}

tools["kristijanhusak/vim-dadbod-ui"] = {
  cmd = { "DBUIToggle", "DBUIAddConnection", "DBUI", "DBUIFindBuffer", "DBUIRenameBuffer" },
  config = conf.vim_dadbod_ui,
  requires = {
    { "tpope/vim-dadbod", opt = true },
    { "kristijanhusak/vim-dadbod-completion", opt = true },
  },
  disable = not rvim.plugin.dadbod.active,
}

return tools
