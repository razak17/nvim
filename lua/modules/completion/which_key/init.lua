return function()
  for opt, val in pairs(rvim.which_key.defaults) do
    vim.g["which_key_" .. opt] = val
  end

  vim.fn["which_key#register"]("<space>", "g:which_key_map")

  _G.WhichKey = {}

  -- Set default keymaps
  vim.g.which_key_map = rvim.which_key.keymaps.defaults

  -- Plugin keymaps
  WhichKey.SetKeyOnFT = function()
    -- Get Which-Key keymap
    local key_maps = vim.g.which_key_map

    -- telescope
    if rvim.plugin.telescope.active then
      key_maps.f = {
        name = "+Telescope",
        b = rvim.wk.telescope.browser,
        c = rvim.wk.telescope.builtin,
        d = rvim.wk.telescope.dotfiles,
        e = rvim.wk.telescope.extensions,
        f = rvim.wk.telescope.files,
        l = rvim.wk.telescope.live,
        r = rvim.wk.telescope.config,
        v = rvim.wk.telescope.lsp,
        g = rvim.wk.telescope.git,
      }
    end

    -- kommentary
    if rvim.plugin.kommentary.active then
      key_maps["/"] = rvim.wk.kommentary["/"]
      key_maps.a["/"] = rvim.wk.kommentary.a["/"]
    end

    -- dap
    if rvim.plugin_loaded "nvim-dap" then
      key_maps.d = rvim.wk.dap
    end

    -- dap ui
    if rvim.plugin_loaded "nvim-dap-ui" then
      key_maps.d.e = rvim.wk.dap_ui.toggle
      key_maps.d.i = rvim.wk.dap_ui.inspect
    end

    rvim.which_key.keymaps.packer = {
      name = "+Plug",
      c = { ":PlugCompile", "compile" },
      C = { ":PlugClean", "clean" },
      D = { ":PackerCompiledDelete", "delete packer_compiled" },
      e = { ":PlugUpdate", "update" },
      E = { ":PackerCompiledEdit", "edit packer_compiled" },
      i = { ":PlugInstall", "install" },
      R = { ":PlugRecompile", "recompile" },
      s = { ":PlugSync", "sync" },
      S = { ":PlugStatus", "Status" },
    }

    if rvim.plugin.packer.active then
      key_maps.E = rvim.which_key.keymaps.packer
    end

    -- fterm
    rvim.which_key.keymaps.fterm = {
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
      key_maps.e = rvim.which_key.keymaps.fterm
    end

    -- far
    rvim.which_key.keymaps.far = {
      name = "+Far",
      f = { ":Farr --source=vimgrep", "replace in File" },
      d = { ":Fardo", "do" },
      i = { ":Farf", "search iteratively" },
      r = { ":Farr --source=rgnvim", "replace in Project" },
      z = { ":Farundo", "undo" },
    }
    if rvim.plugin_loaded "far.vim" then
      key_maps.F = rvim.which_key.keymaps.far
    end
    -- git_signs
    rvim.which_key.keymaps.git_signs = {
      name = "+Gitsigns",
      b = "blame line",
      e = "preview hunk",
      r = "reset hunk",
      s = "stage hunk",
      t = "toggle line blame",
      u = "undo stage hunk",
    }
    if rvim.plugin_loaded "gitsigns.nvim" then
      key_maps.h = rvim.which_key.keymaps.git_signs
    end

    -- fugitive
    rvim.which_key.keymaps.fugitive = {
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
      key_maps.g = rvim.which_key.keymaps.fugitive
    end

    -- lsp
    rvim.which_key.keymaps.lsp = {
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
      key_maps.v = rvim.which_key.keymaps.lsp
      key_maps.L = {
        name = "+LspUtils",
        i = { ":LspInfo", "info" },
        l = { ":LspLog", "log" },
        r = { ":LspReload", "restart" },
      }
    end

    --trouble
    rvim.which_key.keymaps.trouble = {
      name = "+Trouble",
      d = { ":TroubleToggle lsp_document_diagnostics", "document" },
      e = { ":TroubleToggle quickfix", "quickfix" },
      l = { ":TroubleToggle loclist", "loclist" },
      r = { ":TroubleToggle lsp_references", "references" },
      w = { ":TroubleToggle lsp_workspace_diagnostics", "workspace" },
    }
    if rvim.plugin_loaded "trouble.nvim" then
      key_maps.v.x = rvim.which_key.keymaps.trouble
    end

    -- Slide
    rvim.which_key.keymaps.slide = {
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
      key_maps.A = rvim.which_key.keymaps.slide
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
      key_maps.d.E = "osv run this"
      key_maps.d.l = "osv launch"
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
    if rvim.plugin.matchup.active then
      key_maps.v.W = "where am i"
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
