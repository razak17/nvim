return function()
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

  rvim.keymaps = {
    defaults = {
      ["="] = "Balance window",
      ["."] = "append period",
      [","] = "append comma",
      [";"] = "append semi-colon",
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
      I = { name = "+Info", c = "open core/init.lua", C = "check health", m = "messages", v = "open vimrc" },
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
    },
    debug = {
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
    },

    fterm = {
      name = "+Fterm",
      g = "gitui",
      l = "lazygit",
      n = "node",
      N = "new",
      p = "python",
      r = "ranger",
      v = "open vimrc in vertical split",
    },
    far = {
      name = "+Far",
      f = "replace in File",
      d = "do",
      i = "search iteratively",
      r = "replace in Project",
      z = "undo",
    },
    git_signs = {
      name = "+Gitsigns",
      b = "blame line",
      e = "preview hunk",
      r = "reset hunk",
      s = "stage hunk",
      t = "toggle line blame",
      u = "undo stage hunk",
    },
    fugitive = {
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
    },
    telescope = {
      name = "+Telescope",
      b = "file browser",
      c = {
        name = "+Builtin",
        a = "autocmds",
        c = "commands",
        b = "buffers",
        e = "quickfix",
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
      C = "Open lua/rvim/core/config.lua",
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
    },
    lsp = {
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
    },
    slide = {
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
    },
    trouble = {
      name = "+Trouble",
      d = "document",
      e = "quickfix",
      l = "loclist",
      r = "references",
      w = "workspace",
    },
  }

  _G.WhichKey = {}

  -- Set default keymaps
  g.which_key_map = rvim.keymaps.defaults

  -- Plugin keymaps
  WhichKey.SetKeyOnFT = function()
    -- Get Which-Key keymap
    local key_maps = vim.g.which_key_map
    -- Add keys to Which-Key keymap
    -- dap
    if rvim.plugin_loaded "nvim-dap" then
      key_maps.d = rvim.keymaps.debug
    end
    -- fterm
    if rvim.plugin_loaded "FTerm.nvim" then
      key_maps.e = rvim.keymaps.fterm
    end
    -- far
    if rvim.plugin_loaded "far.vim" then
      key_maps.F = rvim.keymaps.far
    end
    -- git_signs
    if rvim.plugin_loaded "gitsigns.nvim" then
      key_maps.h = rvim.keymaps.git_signs
    end
    -- fugitive
    if rvim.plugin_loaded "vim-fugitive" then
      key_maps.g = rvim.keymaps.fugitive
    end
    -- lsp
    if rvim.plugin_loaded "nvim-lspconfig" then
      key_maps.v = rvim.keymaps.lsp
      key_maps.L = { name = "+LspUtils", i = "info", l = "log", r = "restart" }
    end
    --trouble
    if rvim.plugin_loaded "trouble.nvim" then
      key_maps.v.x = rvim.keymaps.trouble
    end
    -- telescope
    if rvim.plugin_loaded "telescope.nvim" then
      key_maps.f = rvim.keymaps.telescope
    end
    -- Slide
    if vim.bo.ft == "slide" then
      key_maps["↵"] = "execute commnd"
      key_maps.A = rvim.keymaps.slide
      key_maps.b.l = "show all open buffers"
      key_maps.B = {
        name = "+Background",
        d = "dark",
        l = "light",
      }
    end
    -- matchup
    if rvim.plugin_loaded "vim-matchup" then
      key_maps.a.w = "where_am_i"
    end
    -- undotree
    if rvim.plugin_loaded "undotree" then
      key_maps.a.u = "toggle undotree"
    end
    -- tree
    if rvim.plugin_loaded "nvim-tree.lua" then
      key_maps.c.c = "nvim-tree close"
      key_maps.c.f = "nvim-tree find"
      key_maps.c.r = "nvim-tree refresh"
      key_maps.c.v = "nvim-tree toggle"
    end
    -- osv
    if rvim.plugin_loaded "one-small-step-for-vimkind" then
      key_maps.d.l = "osv launch"
    end
    -- debug ui
    if rvim.plugin_loaded "nvim-dap-ui" then
      key_maps.d.e = "toggle ui"
      key_maps.d.i = "inspect"
    end
    -- bookmarks
    if rvim.plugin_loaded "vim-bookmarks" then
      key_maps.m = { name = "+Mark", e = "toggle", b = "previous mark", k = "next mark" }
    end
    -- markdown
    if rvim.plugin_loaded "markdown-preview.nvim" or rvim.plugin_loaded "glow.nvim" then
      key_maps.o = { name = "+Toggle", z = "test" }
      if rvim.plugin_loaded "markdown-preview.nvim" then
        key_maps.o.m = "markdown preview"
      end
      if rvim.plugin_loaded "glow.nvim" then
        key_maps.o.g = "glow preview"
      end
    end
    -- dashboard
    if rvim.plugin_loaded "dashboard-nvim" then
      key_maps.S = { name = "+Session", l = "load Session", s = "save Session" }
    end
    -- playground
    if rvim.plugin_loaded "playground" then
      key_maps.a.E = "Inspect token"
    end
    -- treesitter
    if rvim.plugin_loaded "nvim-treesitter" then
      key_maps.I.e = "ts info"
      key_maps.I.u = "ts update"
    end
    -- dashboard
    if rvim.plugin_loaded "dashboard-nvim" then
      key_maps.S = {
        name = "+Session",
        l = "load",
        s = "save",
      }
    end
    -- snippets
    if rvim.plugin_loaded "vim-vsnip" then
      key_maps.c.s = "edit snippet"
    end
    -- DOGE
    if rvim.plugin_loaded "vim-doge" then
      key_maps.v.D = "DOGe"
    end
    -- matchup
    if rvim.plugin_loaded "vim-matchup" then
      key_maps.v.W = "where am i"
    end
    if rvim.plugin_loaded "project.nvim" then
      key_maps.f.e.e = "projects"
    end
    if rvim.plugin_loaded "telescope-media-files.nvim" then
      key_maps.f.e.m = "project"
    end
    if rvim.plugin_loaded "telescope-project.nvim" then
      key_maps.f.e.p = "project"
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
end
