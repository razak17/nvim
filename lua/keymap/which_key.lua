local g, api, fn = vim.g, vim.api, vim.fn

g.which_key_sep = ""
g.which_key_hspace = 2
g.which_key_centered = 1
g.which_key_vertical = 0
g.which_key_timeout = 100
g.which_key_use_floating_win = 0
g.which_key_display_names = { ["<CR>"] = "↵ ", ["<TAB>"] = "⇆ " }

api.nvim_set_keymap("n", "<leader>", ':<c-u> :WhichKey "<space>"<CR>', { noremap = true, silent = true })
api.nvim_set_keymap("v", "<leader>", ':<c-u> :WhichKeyVisual "<space>"<CR>', { noremap = true, silent = true })
fn["which_key#register"]("<space>", "g:which_key_map")

local default_keymaps = {
  ["="] = "Balance window",
  [";"] = "terminal",
  ["."] = "append period to line end",
  [","] = "append comma to line end",
  ["/"] = "Comment",
  ["["] = "Find and Replace all",
  ["]"] = "Find and Replace one",
  ["`"] = "Wrap backticks",
  ["'"] = "Wrap single quotes",
  ['"'] = "Wrap double quotes",
  [")"] = "Wrap parenthesis",
  ["}"] = "Wrap curly braces",
  ["_"] = "Delete current buffer",
  x = "Quit",
  y = "Yank",
  a = {
    name = "+Actions",
    ["/"] = "comment motion default",
    ["."] = "Open init.vim",
    [","] = "Open lua/core/init.lua",
    d = "force delete buffer",
    D = "delete all",
    e = "turn off guides",
    f = {
      name = "+Fold",
      l = "under curosr",
      r = "recursive cursor",
      o = "open all",
      x = "close all",
    },
    F = "resize 90%",
    h = "horizontal split",
    l = "open last buffer",
    n = "no highlight",
    o = "turn on guides",
    O = "open old commands",
    R = "empty registers",
    v = "vertical split",
    V = "select all",
    x = "save and exit",
    Y = "yank all",
    z = "force exit",
  },
  b = {
    name = "+Buffer",
    n = "move next",
    b = "move previous",
    d = { name = "+Delete", a = "all", h = "to left", x = "all except current" },
    s = "highlight cursor word",
  },
  c = { name = "+Command", a = "vertical resize 30", h = { name = "+Help", w = "word" } },
  E = { name = "+Plug", c = "compile", C = "clean", i = "install", s = "sync", e = "update" },
  I = { name = "+Info", c = "check health", m = "messages", v = "vsplit vimrc" },
  l = { name = "+LocList", i = "empty", s = "toggle" },
  n = { name = "+New", f = "open file in same dir", s = "create new file in same dir" },
  s = {
    name = "+Tab",
    b = "previous",
    d = "close",
    H = "move left",
    k = "delete Session",
    K = "last",
    n = "next",
    L = "move right",
    N = "new",
  },
  w = { name = "+Orientation", h = "change to horizontal", v = "change to vertical" },
}

_G.WhichKey = {}

local debug_keymaps = {
  name = "+Debug",
  ["?"] = "centered float ui",
  a = "attach",
  A = "attach remote",
  b = "toggle breakpoint",
  B = "set breakpoint",
  c = "continue",
  C = "run to cursor",
  E = "toggle repl",
  g = "get session",
  k = "up",
  L = "run last",
  n = "down",
  p = "pause",
  r = "open repl in vsplit",
  s = { name = "+Step", b = "back", i = "step into", o = "step out", v = "step over" },
  S = "stop",
  x = "disconnect",
}

local fterm_keymaps = {
  name = "+Fterm",
  g = "gitui",
  l = "lazygit",
  n = "node",
  N = "new",
  p = "python",
  r = "ranger",
  v = "open vimrc in vertical split",
}

local far_keymaps = {
  name = "+Far",
  f = "replace in File",
  d = "do",
  i = "search iteratively",
  r = "replace in Project",
  z = "undo",
}

local git_signs_keymaps = {
  name = "+Gitsigns",
  b = "blame line",
  e = "preview hunk",
  r = "reset hunk",
  s = "stage hunk",
  t = "toggle line blame",
  u = "undo stage hunk",
}

local fugitive_keymaps = {
  name = "+Git",
  a = "fetch all",
  b = "branches",
  A = "blame",
  c = { name = "+Commit", a = "amend", m = "message" },
  C = "checkout",
  d = "diff",
  D = "diff split",
  h = "diffget",
  i = "init",
  k = "diffget",
  l = "log",
  e = "push",
  p = "poosh",
  P = "pull",
  r = "remove",
  s = "status",
}

local telescope_keymaps = {
  name = "+Telescope",
  b = "file browser",
  c = {
    name = "+Builtin",
    a = "autocmds",
    c = "commands",
    b = "buffers",
    f = "builtin",
    h = "help",
    H = "history",
    k = "keymaps",
    l = "loclist",
    r = "registers",
    T = "treesitter",
    v = "vim options",
    z = "current file fuzzy find",
  },
  C = "Open lua/rvim/defaults/init.lua",
  d = {
    name = "+Dotfiles",
    b = "branches",
    B = "bcommits",
    c = "commits",
    f = "git files",
    r = "recent files",
    s = "status",
  },
  e = { name = "+Extensions", b = "change background" },
  f = "find files",
  l = { name = "+Live", g = "grep", w = "current word", e = "prompt" },
  r = {
    name = "+Config",
    b = "branches",
    B = "bcommits",
    c = "commits",
    f = "nvim files",
    r = "recent files",
    s = "status",
  },
  v = {
    name = "+Lsp",
    a = "code action",
    A = "range code action",
    r = "references",
    d = "document_symbol",
    w = "workspace_symbol",
  },
  g = { name = "+Git", b = "branches", c = "commits", C = "bcommits", f = "files", s = "status" },
}

local lsp_keymaps = {
  name = "+Code",
  a = "code action",
  A = "range code action",
  d = { name = "+Diagnostics", b = "goto previous", l = "current line", n = "goto next" },
  f = "format",
  l = "set loc list",
  o = "open qflist",
  s = "Symbols outline",
  v = "toggle virtual text",
  w = { name = "+Color", m = "pencils" },
}

local slide_default_keymaps = {
  name = "+ASCII",
  A = "add 20 less than signs",
  b = "term",
  B = "bfraktur",
  e = "emboss",
  E = "emboss2",
  f = "bigascii12",
  F = "letter",
  m = "bigmono12",
  v = "asciidoc-view",
  w = "wideterm",
}

local trouble_keymaps = {
  name = "+Trouble",
  d = "document",
  e = "quickfix",
  l = "loclist",
  r = "references",
  w = "workspace",
}

-- Set default keymaps
g.which_key_map = default_keymaps

-- Plugin keymaps
WhichKey.SetKeyOnFT = function()
  -- Get Which-Key keymap
  local key_maps = vim.g.which_key_map
  -- Add keys to Which-Key keymap

  -- matchup
  if rvim.plugin.matchup.active then
    key_maps.a.w = "where_am_i"
  end
  -- undotree
  if rvim.plugin.undotree.active then
    key_maps.a.u = "toggle undotree"
  end
  -- tree
  if rvim.plugin.tree.active then
    key_maps.c.f = "nvim-tree find"
    key_maps.c.r = "nvim-tree refresh"
    key_maps.c.v = "nvim-tree toggle"
  end
  -- dap
  if rvim.plugin.debug.active then
    key_maps.d = debug_keymaps
  end
  -- osv
  if rvim.plugin.osv.active then
    key_maps.d.l = "osv launch"
  end
  -- debug ui
  if rvim.plugin.debug_ui.active then
    key_maps.d.e = "toggle ui"
    key_maps.d.i = "inspect"
  end
  -- fterm
  if rvim.plugin.fterm.active or rvim.plugin.SANE.active then
    key_maps.e = fterm_keymaps
  end
  -- far
  if rvim.plugin.far.active then
    key_maps.F = far_keymaps
  end
  -- git_signs
  if rvim.plugin.git_signs.active then
    key_maps.h = git_signs_keymaps
  end
  -- fugitive
  if rvim.plugin.fugitive.active then
    key_maps.g = fugitive_keymaps
  end
  -- bookmarks
  if rvim.plugin.bookmarks.active then
    key_maps.m = { name = "+Mark", e = "toggle", b = "previous mark", k = "next mark" }
  end
  -- markdown
  if rvim.plugin.markdown_preview.active or rvim.plugin.glow.active then
    key_maps.o = { name = "+Toggle" }
    if rvim.plugin.markdown_preview.active then
      key_maps.o.m = "markdown preview"
    end
    if rvim.plugin.glow.active then
      key_maps.o.g = "glow preview"
    end
  end
  -- dashboard
  if rvim.plugin.dashboard.active then
    key_maps.S = { name = "+Session", l = "load Session", s = "save Session" }
  end
  -- SANE
  if rvim.plugin.playground.active then
    key_maps.a.E = "Inspect token"
  end
  if rvim.plugin.SANE.active then
    key_maps.c.s = "edit snippet"
    key_maps.I.e = "ts info"
    key_maps.I.u = "ts update"
    key_maps.L = { name = "+LspUtils", i = "info", l = "log", r = "restart" }
    key_maps.f = telescope_keymaps
    key_maps.v = lsp_keymaps
    key_maps.S = {
      name = "+Session",
      l = "load",
      s = "save",
    }
    if rvim.plugin.doge.active then
      key_maps.v.D = "DOGe"
    end
    if rvim.plugin.trouble.active then
      key_maps.v.x = trouble_keymaps
    end
    if rvim.plugin.matchup.active then
      key_maps.v.W = "where am i"
    end
  end
  if rvim.plugin.telescope_media_files.active then
    key_maps.f.e.m = "project"
  end
  if rvim.plugin.telescope_project.active then
    key_maps.f.e.p = "project"
  end
  -- Slide
  if vim.bo.ft == "slide" then
    key_maps["↵"] = "execute commnd"
    key_maps.A = slide_default_keymaps
    key_maps.b.l = "show all open buffers"
    key_maps.B = {
      name = "+Background",
      d = "dark",
      l = "light",
    }
  end

  -- Update Which-Key keymap
  vim.g.which_key_map = key_maps
end

rvim.augroup("WhichKeySetKeyOnFT", {
  { events = { "BufEnter" }, targets = { "*" }, command = "call v:lua.WhichKey.SetKeyOnFT()" },
})

rvim.augroup("WhichKeyMode", {
  {
    events = { "FileType" },
    targets = { "which_key" },
    command = "set laststatus=0 noshowmode | autocmd BufLeave <buffer> set laststatus=2",
  },
})
