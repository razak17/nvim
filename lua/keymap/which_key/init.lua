local g, api, fn = vim.g, vim.api, vim.fn

g.which_key_sep = ''
g.which_key_timeout = 100
g.which_key_use_floating_win = 0
g.which_key_display_names = {['<CR>'] = '↵', ['<TAB>'] = '⇆'}

api.nvim_set_keymap('n', "<leader>", ":<c-u> :WhichKey '<space>'<CR>",
                    {noremap = true, silent = true})
api.nvim_set_keymap('v', "<leader>", ":<c-u> :WhichKeyVisual '<space>'<CR>",
                    {noremap = true, silent = true})
fn['which_key#register']('<space>', 'g:which_key_map')

g.which_key_map = {
  ["="] = "Balance window",
  ['"'] = "Open peekup window",
  [";"] = "terminal",
  ["."] = "Open init.vim",
  [","] = "Open lua/init.lua",
  ["/"] = "Comment",
  ["<CR>"] = "Source init.vim",
  x = "Quit",
  y = "Yank",
  a = {
    name = "+Actions",
    ["/"] = "comment motion default",
    d = "force delete buffer",
    D = "delete all",
    e = "turn off guides",
    f = {
      name = "+Fold",
      l = "under curosr",
      r = "recursive cursor",
      o = "open all",
      x = "close all"
    },
    F = "resize 90%",
    h = "horizontal split",
    n = "no highlight",
    N = "toggle line numbers",
    o = "turn on guides",
    r = "toggle rnvimr",
    R = "toggle relative line numbers",
    s = "save and exit",
    u = "undotreeToggle",
    v = "vertical split",
    V = "select all",
    x = "save and exit",
    Y = "yank all",
    z = "force exit"
  },
  b = {
    name = "+Buffer",
    n = "move next",
    b = "move previous",
    d = {
      name = "+Delete buffer",
      A = "all",
      h = "to left",
      x = "all except current"
    },

    s = "word"
  },
  c = {
    name = "+Command",
    a = "vertical resize 30",
    c = "Toggle context",
    h = {name = "+Help", w = "word"},
    f = "nvim-tree find",
    r = "nvim-tree refresh",
    R = "empty registers",
    s = "edit snippet",
    v = "nvim-tree toggle"
  },
  d = {
    name = "+Debug",
    c = "continue",
    s = {name = "+Step", i = "into", o = "out", v = "over"}
  },
  e = {
    name = "+Floaterm",
    e = 'toggle',
    l = 'lazygit',
    n = 'node',
    N = 'new terminal',
    p = 'python',
    r = 'ranger',
    x = 'Delete current buffer'
  },
  f = {
    name = "+Telescope",
    c = {
      name = "+Command",
      A = "autocmds",
      c = "commands",
      b = "buffers",
      e = "planets",
      f = "builtin",
      h = "help",
      H = "history",
      k = "keymaps",
      l = "loclist",
      o = "old files",
      r = "registers",
      T = "treesitter",
      v = "vim options",
      z = "current file fuzzy find"
    },
    e = {
      name = "+Extensions",
      e = "packer",
      m = "media files",
      b = 'change background',
      p = 'project'
    },
    f = "find files",
    l = {name = "+Live", g = "grep", w = "current word", e = "prompt"},
    r = {name = "+Config", c = "vimrc"},
    v = {
      name = "+Lsp",
      a = "code action",
      r = "references",
      s = {name = "+Symbols", d = "document", w = "workspace"}
    },
    g = {
      name = '+Git',
      b = "branches",
      c = "commits",
      C = "bcommits",
      f = "files",
      s = "status"
    }
  },
  F = {
    name = "+Far",
    f = "replace in File",
    r = "replace in Project",
    z = "replace iteratively"
  },
  g = {
    name = "+Git",
    a = 'fetch all',
    b = 'branches',
    A = 'blame',
    c = {name = '+Commit', a = "amend", m = "message"},
    C = 'checkout',
    d = 'diff',
    D = 'diff split',
    h = 'diffget',
    i = 'init',
    k = 'diffget',
    l = 'log',
    e = 'push',
    p = 'poosh',
    P = 'pull',
    r = 'remove',
    s = 'status'
  },
  I = {name = "+Info", c = "check health", e = "treesitter"},
  l = {
    name = "+Lsp actions",
    f = "format",
    v = "toggle virtual text",
    x = "close quickfix"
  },
  L = {name = "+Lsp utils", i = "info", l = "log", r = "restart"},
  m = {name = "+mark", e = "toggle", b = "previous mark", k = "next mark"},
  P = {
    name = "+Plug",
    c = 'compile',
    C = 'clean',
    i = 'install',
    s = 'sync',
    U = 'update'
  },
  s = {
    name = "+Tab",
    b = 'previous',
    d = 'close',
    H = 'move left',
    k = 'delete Session',
    K = 'last',
    l = 'next',
    L = 'move right',
    N = 'new'
  },
  S = {name = "+Session", l = 'load Session', s = 'save Session'},
  T = {name = "+Treesitter", m = "scope incremental", n = "init selection"},
  v = {
    name = "+Code",
    a = "code action",
    D = "preview definition",
    d = {
      name = "+Diagnostics",
      b = "goto previous",
      l = "set loc list",
      n = "goto next"
    },
    f = "find the cursor word definition and reference",
    l = {name = "+Lsp", r = "rename", s = "signature", e = "type definition"},
    v = "vista",
    w = {name = "+Color", m = "pencils"}
  }
}

