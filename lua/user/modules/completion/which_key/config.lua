return {
  defaults = {
    sep = "",
    hspace = 2,
    centered = 1,
    vertical = 0,
    timeout = 100,
    use_floating_win = 0,
    display_names = { ["<CR>"] = "↵ ", ["<TAB>"] = "⇆ " },
  },
  keymaps = {
    defaults = {
      ["="] = "balance window",
      ["."] = "append period",
      [","] = "append comma",
      [";"] = "append semi-colon",
      ["["] = "find and replace all",
      ["]"] = "find and replace one",
      ["`"] = "wrap backticks",
      ["'"] = "wrap single quotes",
      ['"'] = "wrap double quotes",
      [")"] = "wrap parenthesis",
      ["}"] = "wrap curly braces",
      ["_"] = "Delete current buffer",
      x = { ":q", "Quit" },
      y = "Yank",
      a = {
        name = "+Actions",
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
        F = "vertical resize 90",
        h = "horizontal split",
        l = "open last buffer",
        L = "vertical resize 30%%",
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
        d = {
          name = "+Delete",
          a = "all",
          h = "to left",
          x = "all except current",
        },
        s = "highlight cursor word",
      },
      c = {
        name = "+Command",
        w = "help cword",
      },
      I = {
        name = "+Info",
        c = {
          ":e " .. require("user.utils").join_paths(rvim.get_user_dir(), "config/init.lua"),
          "open config/init.lua",
        },
        C = "check health",
        L = "cache profile",
        m = "messages",
        M = "vim with me",
        v = {
          ":e " .. require("user.utils").join_paths(rvim.get_config_dir(), "init.lua"),
          "open vimrc",
        },
      },
      l = { name = "+LocList", i = "empty", s = "toggle" },
      n = {
        name = "+New",
        f = "open file in same dir",
        s = "create new file in same dir",
      },
      s = {
        name = "+Tab",
        b = "previous",
        d = "close",
        H = "move left",
        k = "delete Session",
        K = "last",
        n = "next",
        o = "source current file",
        L = "move right",
        N = "new",
      },
      w = {
        name = "+Orientation",
        h = "change to horizontal",
        v = "change to vertical",
      },
    },
  },
  telescope = {
    builtin = {
      name = "+Builtin",
      a = { ":Telescope autocommands", "autocmds" },
      b = { ":Telescope buffers", "buffers" },
      c = { ":Telescope commands", "commands" },
      e = { ":Telescope quickfix", "quickfix" },
      f = { ":Telescope builtin", "builtin" },
      h = { ":Telescope help_tags", "help" },
      H = { ":Telescope command_history", "history" },
      k = { ":Telescope keymaps", "keymaps" },
      l = { ":Telescope loclist", "loclist" },
      r = { ":Telescope registers<CR>", "registers" },
      T = { ":Telescope treesitter", "treesitter" },
      v = { ":Telescope vim_options", "vim options" },
      z = { ":Telescope current_buffer_fuzzy_find", "current file fuzzy find" },
    },
    dotfiles = {
      name = "+Dotfiles",
      b = { ":Telescope dotfiles branches", "branches" },
      B = { ":Telescope dotfiles bcommits", "bcommits" },
      c = { ":Telescope dotfiles commits", "commits" },
      f = { ":Telescope dotfiles git_files", "git files" },
      s = { ":Telescope dotfiles status", "status" },
    },
    config = {
      name = "+Config",
      b = { ":Telescope nvim_files branches", "branches" },
      B = { ":Telescope nvim_files bcommits", "bcommits" },
      c = { ":Telescope nvim_files commits", "commits" },
      f = { ":Telescope nvim_files files", "nvim files" },
      g = { ":Telescope nvim_files grep_files", "grep files" },
      I = { ":Telescope nvim_files view_changelog", "view changelog" },
      s = { ":Telescope nvim_files status", "status" },
    },
    git = {
      name = "+Git",
      b = { ":Telescope git_branches", "branches" },
      c = { ":Telescope git_commits", "commits" },
      C = { ":Telescope git_bcommits", "bcommits" },
      f = { ":Telescope git_files", "files" },
      s = { ":Telescope git_status", "status" },
    },
    lsp = {
      name = "+Lsp",
      a = { ":Telescope lsp_code_actions", "code action" },
      A = { ":Telescope lsp_range_code_actions", "range code action" },
      r = { ":Telescope lsp_references", "references" },
      d = { ":Telescope lsp_document_symbols", "document_symbol" },
      w = { ":Telescope lsp_workspace_symbols", "workspace_symbol" },
    },
    extensions = {
      name = "+Extensions",
      b = { ":Telescope bg_selector", "change background" },
    },
    live = {
      name = "+Live",
      g = { ":Telescope live_grep", "grep" },
      w = { ":Telescope grep_string", "current word" },
      e = { ":Telescope grep_string_prompt", "prompt" },
    },
    files = {
      ":Telescope find_files",
      "find files",
    },
    oldfiles = { ":Telescope oldfiles", "recent files" },
    frecency = { ":Telescope frecency", "history" },
    browser = { ":Telescope file_browser", "file browser" },
    tmux = {
      name = "+Tmux",
      s = { ":Telescope tmux sessions", "sessions" },
      w = { ":Telescope tmux windows", "windows" },
      e = { ":Telescope tmux pane_contents", "pane contents" },
    },
  },
  kommentary = {
    ["/"] = { "<Plug>kommentary_line_default", "comment" },
    a = { ["/"] = { "<Plug>kommentary_motion_default", "comment motion default" } },
  },
  dap = {
    name = "+Debug",
    ["?"] = "centered float ui",
    a = "attach",
    A = "attach remote",
    b = "toggle breakpoint",
    B = "set breakpoint",
    c = "continue",
    C = "run to cursor",
    g = "get session",
    k = "up",
    L = "run last",
    n = "down",
    p = "pause",
    r = "toggle repl",
    R = "open repl in vsplit",
    s = {
      name = "+Step",
      b = "back",
      i = "step into",
      o = "step out",
      v = "step over",
    },
    S = { ':lua require"dap".close()', "stop" },
    x = { ':lua require"dap".disconnect()', "disconnect" },
  },
  dap_ui = {
    toggle = {
      ':lua require"dapui".toggle()',
      "toggle ui",
    },
    inspect = {
      ':lua require"dap.ui.variables".hover()',
      "inspect",
    },
  },
  packer = {
    name = "+Plug",
    c = { ":PlugCompile", "compile" },
    C = { ":PlugClean", "clean" },
    D = { ":PlugCompiledDelete", "delete packer_compiled" },
    u = { ":PlugUpdate", "update" },
    E = { ":PlugCompiledEdit", "edit packer_compiled" },
    i = { ":PlugInstall", "install" },
    R = { ":PlugRecompile", "recompile" },
    s = { ":PlugSync", "sync" },
    S = { ":PlugStatus", "Status" },
  },
  fterm = {
    name = "+Fterm",
    g = { [[v:lua.fterm_cmd("gitui")]], "gitui" },
    l = { [[v:lua.fterm_cmd("lazygit")]], "lazygit" },
    N = { [[v:lua.fterm_cmd("node")]], "node" },
    [";"] = "new",
    p = { [[v:lua.fterm_cmd("python")]], "python" },
    r = { [[v:lua.fterm_cmd("ranger")]], "ranger" },
    v = "open vimrc in vertical split",
  },
  far = {
    name = "+Far",
    f = { ":Farr --source=vimgrep", "replace in File" },
    d = { ":Fardo", "do" },
    i = { ":Farf", "search iteratively" },
    r = { ":Farr --source=rgnvim", "replace in Project" },
    z = { ":Farundo", "undo" },
  },
  gitsigns = {
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
    a = { ":Git fetch --all", "fetch all" },
    A = { ":Git blame", "blame" },
    b = { ":GBranches", "branches" },
    c = {
      name = "+Commit",
      a = { ":Git commit --amend -m ", "amend" },
      m = { ":Git commit<CR>", "message" },
    },
    C = { ":Git checkout -b ", "checkout" },
    d = { ":Git diff", "diff" },
    D = { ":Gdiffsplit", "diff split" },
    h = { ":diffget //3", "diffget" },
    i = { ":Git init", "init" },
    k = { ":diffget //2", "diffget" },
    l = { ":Git log", "log" },
    e = { ":Git push", "push" },
    p = { ":Git poosh", "poosh" },
    P = { ":Git pull", "pull" },
    r = { ":GRemove", "remove" },
    s = { ":G", "status" },
  },
  lsp = {
    name = "+Code",
    a = "code action",
    A = "range code action",
    d = {
      name = "+Diagnostics",
      b = "goto previous",
      d = { ":LspDiagnostics", "toggle quickfix diagnostics" },
      l = "current line",
      n = "goto next",
    },
    f = "format",
    l = "set loc list",
    o = "open qflist",
    s = { ":SymbolsOutline", "Symbols outline" },
    v = { ":LspToggleVirtualText", "toggle virtual text" },
  },
  lsp_utils = {
    name = "+LspUtils",
    i = { ":LspInfo", "info" },
    I = "installer",
    l = { ":LspLog", "log" },
    r = { ":LspReload", "restart" },
  },
  trouble = {
    name = "+Trouble",
    d = { ":TroubleToggle lsp_document_diagnostics", "document" },
    e = { ":TroubleToggle quickfix", "quickfix" },
    l = { ":TroubleToggle loclist", "loclist" },
    r = { ":TroubleToggle lsp_references", "references" },
    w = { ":TroubleToggle lsp_workspace_diagnostics", "workspace" },
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
  bookmarks = {
    name = "+Mark",
    e = { ":BookmarkToggle", "toggle" },
    b = { ":BookmarkPrev", "previous mark" },
    k = { ":BookmarkNext", "next mark" },
  },
  dashboard = {
    name = "+Session",
    l = { ":SessionLoad", "load Session" },
    s = { ":SessionSave", "save Session" },
  },
}
