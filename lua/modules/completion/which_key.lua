return function()
  local g, api, fn = vim.g, vim.api, vim.fn
  local utils = require "utils"

  g.which_key_sep = ""
  g.which_key_hspace = 2
  g.which_key_centered = 1
  g.which_key_vertical = 0
  g.which_key_timeout = 100
  g.which_key_use_floating_win = 0
  g.which_key_display_names = { ["<CR>"] = "↵ ", ["<TAB>"] = "⇆ " }

  api.nvim_set_keymap("n", "<leader>", ':<c-u> :WhichKey "<space>"<CR>', { noremap = true, silent = true })
  api.nvim_set_keymap("n", "<localleader>", ':<c-u> :WhichKey "<space>"<CR>', { noremap = true, silent = true })
  api.nvim_set_keymap("v", "<leader>", ':<c-u> :WhichKeyVisual "<space>"<CR>', { noremap = true, silent = true })
  fn["which_key#register"]("<space>", "g:which_key_map")

  rvim.keymaps = {
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
        d = { name = "+Delete", a = "all", h = "to left", x = "all except current" },
        s = "highlight cursor word",
      },
      c = { name = "+Command", a = "vertical resize 30", h = { name = "+Help", w = "word" } },
      I = {
        name = "+Info",
        c = {
          ":e " .. utils.join_paths(get_config_dir(), "lua/config/init.lua"),
          "open config/init.lua",
        },
        C = "check health",
        m = "messages",
        M = "vim with me",
        v = {
          ":e " .. utils.join_paths(get_config_dir(), "init.lua"),
          "open vimrc",
        },
      },
      l = { name = "+LocList", i = "empty", s = "toggle" },
      n = { name = "+New", f = "open file in same dir", s = "create new file in same dir" },
      -- o = { name = "+Toggle", e = "quickfix" },
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
  }

  _G.WhichKey = {}

  -- Set default keymaps
  g.which_key_map = rvim.keymaps.defaults

  -- Plugin keymaps
  WhichKey.SetKeyOnFT = function()
    -- Get Which-Key keymap
    local key_maps = vim.g.which_key_map

    local telescope_builtin_keymaps = {
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
    }

    local telescope_dotfiles_keymaps = {
      name = "+Dotfiles",
      b = { ":Telescope dotfiles branches", "branches" },
      B = { ":Telescope dotfiles bcommits", "bcommits" },
      c = { ":Telescope dotfiles commits", "commits" },
      f = { ":Telescope dotfiles git_files", "git files" },
      s = { ":Telescope dotfiles status", "status" },
    }

    local telescope_config_keymaps = {
      name = "+Config",
      b = { ":Telescope nvim_files branches", "branches" },
      B = { ":Telescope nvim_files bcommits", "bcommits" },
      c = { ":Telescope nvim_files commits", "commits" },
      f = { ":Telescope nvim_files files", "nvim files" },
      r = { ":Telescope oldfiles", "recent files" },
      s = { ":Telescope nvim_files status", "status" },
    }

    local telescope_git_keymaps = {
      name = "+Git",
      b = { ":Telescope git_branches", "branches" },
      c = { ":Telescope git_commits", "commits" },
      C = { ":Telescope git_bcommits", "bcommits" },
      f = { ":Telescope git_files", "files" },
      s = { ":Telescope git_status", "status" },
    }

    local telescope_lsp_keymaps = {
      name = "+Lsp",
      a = { ":Telescope lsp_code_actions", "code action" },
      A = { ":Telescope lsp_range_code_actions", "range code action" },
      r = { ":Telescope lsp_references", "references" },
      d = { ":Telescope lsp_document_symbols", "document_symbol" },
      w = { ":Telescope lsp_workspace_symbols", "workspace_symbol" },
    }

    -- kommentary
    key_maps["/"] = { "<Plug>kommentary_line_default", "comment" }
    key_maps.a["/"] = { "<Plug>kommentary_motion_default", "comment motion default" }

    -- dap
    rvim.keymaps.debug = {
      name = "+Debug",
      ["?"] = "centered float ui",
      a = { ':lua require"debug.utils".attach()', "attach" },
      A = { ':lua require"debug.utils".attachToRemote()', "attach remote" },
      b = { ':lua require"dap".toggle_breakpoint()', "toggle breakpoint" },
      B = { ':lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))', "set breakpoint" },
      c = { ':lua require"dap".continue()', "continue" },
      C = { ':lua require"dap".run_to_cursor()', "run to cursor" },
      E = { ':lua require"dap".repl.toggle()', "toggle repl" },
      g = { ':lua require"dap".session()', "get session" },
      k = { ':lua require"dap".up()', "up" },
      L = { ':lua require"dap".run_last()', "run last" },
      n = { ':lua require"dap".down()', "down" },
      p = { ':lua require"dap".pause.toggle()', "pause" },
      r = { ':lua require"dap".repl.open({}, "vsplit")<CR><C-w>l', "open repl in vsplit" },
      s = {
        name = "+Step",
        b = { ':lua require"dap".step_back()', "back" },
        i = { ':lua require"dap".step_into()', "step into" },
        o = { ':lua require"dap".step_out()', "step out" },
        v = { ':lua require"dap".step_over()', "step over" },
      },
      S = { ':lua require"dap".close()', "stop" },
      x = { ':lua require"dap".disconnect()', "disconnect" },
    }
    if rvim.plugin_loaded "nvim-dap" then
      key_maps.d = rvim.keymaps.debug
    end

    rvim.keymaps.packer = {
      name = "+Plug",
      c = { ":PlugCompile", "compile" },
      C = { ":PlugClean", "clean" },
      i = { ":PlugInstall", "install" },
      R = { ":PlugRecompile", "recompile" },
      s = { ":PlugSync", "sync" },
      S = { ":PlugStatus", "Status" },
      e = { ":PlugUpdate", "update" },
    }

    if rvim.plugin.packer.active then
      key_maps.E = rvim.keymaps.packer
    end

    -- fterm
    rvim.keymaps.fterm = {
      name = "+Fterm",
      g = { [[v:lua.fterm_cmd("gitui")]], "gitui" },
      l = { [[v:lua.fterm_cmd("lazygit")]], "lazygit" },
      N = { [[v:lua.fterm_cmd("node")]], "node" },
      n = "new",
      p = { [[v:lua.fterm_cmd("python")]], "python" },
      r = { [[v:lua.fterm_cmd("ranger")]], "ranger" },
      v = "open vimrc in vertical split",
    }
    if rvim.plugin_loaded "FTerm.nvim" then
      key_maps.e = rvim.keymaps.fterm
    end

    -- far
    rvim.keymaps.far = {
      name = "+Far",
      f = { ":Farr --source=vimgrep", "replace in File" },
      d = { ":Fardo", "do" },
      i = { ":Farf", "search iteratively" },
      r = { ":Farr --source=rgnvim", "replace in Project" },
      z = { ":Farundo", "undo" },
    }
    if rvim.plugin_loaded "far.vim" then
      key_maps.F = rvim.keymaps.far
    end
    -- git_signs
    rvim.keymaps.git_signs = {
      name = "+Gitsigns",
      b = "blame line",
      e = "preview hunk",
      r = "reset hunk",
      s = "stage hunk",
      t = "toggle line blame",
      u = "undo stage hunk",
    }
    if rvim.plugin_loaded "gitsigns.nvim" then
      key_maps.h = rvim.keymaps.git_signs
    end

    -- fugitive
    rvim.keymaps.fugitive = {
      name = "+Git",
      a = { ":Git fetch --all", "fetch all" },
      A = { ":Git blame", "blame" },
      b = { ":GBranches", "branches" },
      c = { name = "+Commit", a = { ":Git commit --amend -m ", "amend" }, m = { ":Git commit<CR>", "message" } },
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
    }
    if rvim.plugin_loaded "vim-fugitive" then
      key_maps.g = rvim.keymaps.fugitive
    end

    -- lsp
    rvim.keymaps.lsp = {
      name = "+Code",
      a = "code action",
      A = "range code action",
      d = { name = "+Diagnostics", b = "goto previous", l = "current line", n = "goto next" },
      f = "format",
      l = "set loc list",
      o = "open qflist",
      s = { ":SymbolsOutline", "Symbols outline" },
      v = { ":LspToggleVirtualText", "toggle virtual text" },
    }
    if rvim.plugin_loaded "nvim-lspconfig" then
      key_maps.v = rvim.keymaps.lsp
      key_maps.L = {
        name = "+LspUtils",
        i = { ":LspInfo", "info" },
        l = { ":LspLog", "log" },
        r = { ":LspReload", "restart" },
      }
    end

    --trouble
    rvim.keymaps.trouble = {
      name = "+Trouble",
      d = { ":TroubleToggle lsp_document_diagnostics", "document" },
      e = { ":TroubleToggle quickfix", "quickfix" },
      l = { ":TroubleToggle loclist", "loclist" },
      r = { ":TroubleToggle lsp_references", "references" },
      w = { ":TroubleToggle lsp_workspace_diagnostics", "workspace" },
    }
    if rvim.plugin_loaded "trouble.nvim" then
      key_maps.v.x = rvim.keymaps.trouble
    end

    -- telescope
    rvim.keymaps.telescope = {
      name = "+Telescope",
      b = { ":Telescope file_browser", "file browser" },
      c = telescope_builtin_keymaps,
      d = telescope_dotfiles_keymaps,
      e = { name = "+Extensions", b = { ":Telescope bg_selector", "change background" } },
      f = { ":Telescope find_files", "find files" },
      l = {
        name = "+Live",
        g = { ":Telescope live_grep", "grep" },
        w = { ":Telescope grep_string", "current word" },
        e = { ":Telescope grep_string_prompt", "prompt" },
      },
      r = telescope_config_keymaps,
      v = telescope_lsp_keymaps,
      g = telescope_git_keymaps,
    }

    if rvim.plugin_loaded "telescope.nvim" then
      key_maps.f = rvim.keymaps.telescope
    end

    -- Slide
    rvim.keymaps.slide = {
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
      key_maps.a.u = { ":UndotreeToggle", "toggle undotree" }
    end

    -- tree
    if rvim.plugin_loaded "nvim-tree.lua" then
      key_maps.c.c = { ":NvimTreeClose", "nvim-tree close" }
      key_maps.c.f = { ":NvimTreeFindFile", "nvim-tree find" }
      key_maps.c.r = { ":NvimTreeRefresh", "nvim-tree refresh" }
      key_maps.c.v = { ":NvimTreeToggle", "nvim-tree toggle" }
    end

    -- osv
    if rvim.plugin_loaded "one-small-step-for-vimkind" then
      key_maps.d.l = { ':lua require"osv".launch()', "osv launch" }
    end

    -- debug ui
    if rvim.plugin_loaded "nvim-dap-ui" then
      key_maps.d.e = { ':lua require"dapui".toggle()', "toggle ui" }
      key_maps.d.i = { ':lua require"dap.ui.variables".hover()', "inspect" }
    end

    -- bookmarks
    if rvim.plugin_loaded "vim-bookmarks" then
      key_maps.m = {
        name = "+Mark",
        e = { ":BookmarkToggle", "toggle" },
        b = { ":BookmarkPrev", "previous mark" },
        k = { ":BookmarkNext", "next mark" },
      }
    end

    -- markdown
    if rvim.plugin_loaded "markdown-preview.nvim" or rvim.plugin_loaded "glow.nvim" then
      if rvim.plugin_loaded "markdown-preview.nvim" then
        key_maps.o.m = { ":MarkdownPreview", "markdown preview" }
      end
      if rvim.plugin_loaded "glow.nvim" then
        key_maps.o.g = { ":Glow", "glow preview" }
      end
    end

    -- dashboard
    if rvim.plugin_loaded "dashboard-nvim" then
      key_maps.S = { name = "+Session", l = { ":SessionLoad", "load Session" }, s = { ":SessionSave", "save Session" } }
    end

    -- playground
    if rvim.plugin.playground.active then
      key_maps.a.I = { ":TSPlaygroundToggle", "toggle ts playground" }
      if rvim.plugin_loaded "playground" then
        key_maps.a.E = "Inspect token"
      end
    end

    -- treesitter
    if rvim.plugin_loaded "nvim-treesitter" then
      key_maps.I.e = { ":TSInstallInfo", "ts info" }
      key_maps.I.u = { ":TSUpdate", "ts update" }
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
      key_maps.f.e.e = { ":Telescope projects", "projects" }
    end
    if rvim.plugin_loaded "telescope-media-files.nvim" then
      key_maps.f.e.m = { ":Telescope media_files", "media files" }
    end
    if rvim.plugin_loaded "telescope-project.nvim" then
      key_maps.f.e.p = { ":Telescope project", "project" }
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
