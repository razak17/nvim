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
        a = "vertical resize 30",
        h = {
          name = "+Help",
          w = "word",
        },
      },
      I = {
        name = "+Info",
        c = {
          ":e " .. require("utils").join_paths(get_config_dir(), "lua/config/init.lua"),
          "open config/init.lua",
        },
        C = "check health",
        m = "messages",
        M = "vim with me",
        v = {
          ":e " .. require("utils").join_paths(get_config_dir(), "init.lua"),
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
      r = { ":Telescope oldfiles", "recent files" },
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
    browser = { ":Telescope file_browser", "file browser" },
  },
}
