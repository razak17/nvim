return {
  keymaps = {
    defaults = {
      ["="] = "balance window",
      ["."] = "append period",
      [","] = "append comma",
      [";"] = "append semi-colon",
      ["["] = "replace in file",
      ["]"] = "replace in line",
      ["`"] = "wrap backticks",
      ["'"] = "wrap single quotes",
      ['"'] = "wrap double quotes",
      [")"] = "wrap parenthesis",
      ["}"] = "wrap curly braces",
      -- ["<space>"] = "Switch to prev files",
      B = "highlight word",
      c = { ":bdelete<CR>", "close buffer" },
      x = { ":q<CR>", "Quit" },
      y = "yank",
      A = "select all",
      H = { ':h <C-R>=expand("<cword>")<CR><CR>', "help cword" },
      D = "close all",
      S = "edit snippet",
      U = "capitalize word",
      Y = "yank all",
      a = {
        name = "+Actions",
        [";"] = "open terminal",
        d = { ":bdelete!<CR>", "force delete buffer" },
        e = "turn off guides",
        f = {
          name = "+Fold",
          l = "under curosr",
          r = "recursive cursor",
          o = "open all",
          x = "close all",
        },
        F = { ":vertical resize 90<CR>", "vertical resize 90" },
        h = "horizontal split",
        l = "open last buffer",
        L = { ":vertical resize 40<CR>", "vertical resize 30%%" },
        n = "no highlight",
        o = "turn on guides",
        O = { ":<C-f>:resize 10<CR>", "open old commands" },
        R = "empty registers",
        v = "vertical split",
        x = { ":wq!<CR>", "save and exit" },
        s = { ":w!<CR>", "force save" },
        z = { ":q<CR>", "force exit" },
      },
      b = {
        name = "+Bufferline",
        c = "close all others",
        H = "close to left",
        x = "close all",
      },
      I = {
        name = "+Info",
        c = {
          ":e " .. require("user.utils").join_paths(rvim.get_user_dir(), "config/init.lua<CR>"),
          "open config/init.lua",
        },
        C = { ":checkhealth<CR>", "check health" },
        L = { ":LuaCacheProfile<CR>", "cache profile" },
        m = { ":messages<CR>", "messages" },
        M = "vim with me",
        v = {
          ":e " .. require("user.utils").join_paths(rvim.get_config_dir(), "init.lua"),
          "open vimrc",
        },
      },
      n = {
        name = "+New",
        f = "open file in same dir",
        s = "create new file in same dir",
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
      a = { ":Telescope autocommands<CR>", "autocmds" },
      b = { ":Telescope buffers<CR>", "buffers" },
      c = { ":Telescope commands<CR>", "commands" },
      e = { ":Telescope quickfix<CR>", "quickfix" },
      f = { ":Telescope builtin<CR>", "builtin" },
      h = { ":Telescope help_tags<CR>", "help" },
      H = { ":Telescope command_history<CR>", "history" },
      k = { ":Telescope keymaps<CR>", "keymaps" },
      l = { ":Telescope loclist<CR>", "loclist" },
      r = { ":Telescope registers<CR><CR>", "registers" },
      T = { ":Telescope treesitter", "treesitter" },
      v = { ":Telescope vim_options<CR>", "vim options" },
      z = { ":Telescope current_buffer_fuzzy_find<CR>", "current file fuzzy find" },
    },
    dotfiles = {
      name = "+Dotfiles",
      b = { ":Telescope dotfiles branches<CR>", "branches" },
      B = { ":Telescope dotfiles bcommits<CR>", "bcommits" },
      c = { ":Telescope dotfiles commits<CR>", "commits" },
      f = { ":Telescope dotfiles git_files<CR>", "git files" },
      s = { ":Telescope dotfiles status<CR>", "status" },
    },
    config = {
      name = "+Config",
      b = { ":Telescope nvim_files branches<CR>", "branches" },
      B = { ":Telescope nvim_files bcommits<CR>", "bcommits" },
      c = { ":Telescope nvim_files commits<CR>", "commits" },
      f = { ":Telescope nvim_files files<CR>", "nvim files" },
      g = { ":Telescope nvim_files grep_files<CR>", "grep files" },
      I = { ":Telescope nvim_files view_changelog<CR>", "view changelog" },
      s = { ":Telescope nvim_files status<CR>", "status" },
    },
    git = {
      name = "+Git",
      b = { ":Telescope git_branches<CR>", "branches" },
      c = { ":Telescope git_commits<CR>", "commits" },
      C = { ":Telescope git_bcommits<CR>", "bcommits" },
      f = { ":Telescope git_files<CR>", "files" },
      s = { ":Telescope git_status<CR>", "status" },
    },
    lsp = {
      name = "+Lsp",
      a = { ":Telescope lsp_code_actions<CR>", "code action" },
      A = { ":Telescope lsp_range_code_actions<CR>", "range code action" },
      r = { ":Telescope lsp_references<CR>", "references" },
      d = { ":Telescope lsp_document_symbols<CR>", "document_symbol" },
      w = { ":Telescope lsp_workspace_symbols<CR>", "workspace_symbol" },
    },
    extensions = {
      name = "+Extensions",
      b = { ":Telescope bg_selector<CR>", "change background" },
    },
    live = {
      name = "+Live",
      g = { ":Telescope live_grep<CR>", "grep" },
      w = { ":Telescope grep_string<CR>", "current word" },
      e = { ":Telescope grep_string_prompt<CR>", "prompt" },
    },
    files = {
      ":Telescope find_files<CR>",
      "find files",
    },
    oldfiles = { ":Telescope oldfiles<CR>", "recent files" },
    frecency = { ":Telescope frecency<CR>", "history" },
    browser = { ":Telescope file_browser<CR>", "file browser" },
    tmux = {
      name = "+Tmux",
      s = { ":Telescope tmux sessions<CR>", "sessions" },
      w = { ":Telescope tmux windows<CR>", "windows" },
      e = { ":Telescope tmux pane_contents<CR>", "pane contents" },
    },
  },
  lsp = {
    name = "+Lsp",
    a = "code action",
    A = "range code action",
    d = { ":LspLog<CR>", "log" },
    f = "format",
    i = { ":LspInfo<CR>", "info" },
    j = "next diagnostic",
    k = "prev diagnostic",
    I = { ":LspInstallInfo<CR>", "installer info" },
    n = { ":NullLsInfo<CR>", "null-ls info" },
    N = { ":NlspBufConfig<CR>", "nlsp config" },
    p = {
      name = "+Peek",
      d = "definition",
      i = "implementation",
      t = "type defintion",
    },
    r = { ":LspReload<CR>", "restart" },
    l = "set loclist",
    L = "toggle locflist",
    s = { ":Telescope lsp_document_symbols<CR>", "document symbols" },
    S = { ":Telescope lsp_dynamic_workspace_symbols<CR>", "workspace symbols" },
    w = "set qflist",
    W = "toggle qflist",
    x = "empty qflist",
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
    c = { ":PlugCompile<CR>", "compile" },
    C = { ":PlugClean<CR>", "clean" },
    d = { ":PlugCompiledDelete<CR>", "delete packer_compiled" },
    u = { ":PlugUpdate<CR>", "update" },
    e = { ":PlugCompiledEdit<CR>", "edit packer_compiled" },
    i = { ":PlugInstall<CR>", "install" },
    r = { ":PlugRecompile<CR>", "recompile" },
    s = { ":PlugSync<CR>", "sync" },
    S = { ":PlugStatus<CR>", "Status" },
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
    f = { ":Farr --source=vimgrep<CR>", "replace in File" },
    d = { ":Fardo<CR>", "do" },
    i = { ":Farf<CR>", "search iteratively" },
    r = { ":Farr --source=rgnvim<CR>", "replace in Project" },
    z = { ":Farundo<CR>", "undo" },
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
    a = { ":Git fetch --all<CR>", "fetch all" },
    A = { ":Git blame<CR>", "blame" },
    b = { ":GBranches<CR>", "branches" },
    c = {
      name = "+Commit",
      a = { ":Git commit --amend -m <CR>", "amend" },
      m = { ":Git commit<CR><CR>", "message" },
    },
    C = { ":Git checkout -b <CR>", "checkout" },
    d = { ":Git diff<CR>", "diff" },
    D = { ":Gdiffsplit<CR>", "diff split" },
    h = { ":diffget //3<CR>", "diffget" },
    i = { ":Git init<CR>", "init" },
    k = { ":diffget //2<CR>", "diffget" },
    l = { ":Git log<CR>", "log" },
    e = { ":Git push<CR>", "push" },
    p = { ":Git poosh<CR>", "poosh" },
    P = { ":Git pull<CR>", "pull" },
    r = { ":GRemove<CR>", "remove" },
    s = { ":G<CR>", "status" },
  },
  trouble = {
    name = "+Trouble",
    d = { ":TroubleToggle lsp_document_diagnostics<CR>", "document" },
    e = { ":TroubleToggle quickfix<CR>", "quickfix" },
    l = { ":TroubleToggle loclist<CR>", "loclist" },
    r = { ":TroubleToggle lsp_references<CR>", "references" },
    w = { ":TroubleToggle lsp_workspace_diagnostics<CR>", "workspace" },
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
    e = { ":BookmarkToggle<CR>", "toggle" },
    b = { ":BookmarkPrev<CR>", "previous mark" },
    k = { ":BookmarkNext<CR>", "next mark" },
  },
  dashboard = {
    name = "+Session",
    l = { ":SessionLoad<CR>", "load Session" },
    s = { ":SessionSave<CR>", "save Session" },
  },
}
