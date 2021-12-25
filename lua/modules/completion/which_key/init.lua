return function()
  for opt, val in pairs(rvim.wk.defaults) do
    vim.g["which_key_" .. opt] = val
  end

  vim.fn["which_key#register"]("<space>", "g:which_key_map")

  _G.WhichKey = {}

  -- Set default keymaps
  vim.g.which_key_map = rvim.wk.keymaps.defaults

  -- plugin keymaps
  WhichKey.SetKeyOnFT = function()
    -- Get Which-Key keymap
    local key_maps = vim.g.which_key_map

    -- bookmarks
    if rvim.plugin_loaded "vim-bookmarks" then
      key_maps.m = rvim.wk.bookmarks
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

    -- dashboard
    -- if rvim.plugin_loaded "dashboard-nvim" then
    --   key_maps.S = rvim.wk.dashboard
    -- end

    -- DOGE
    if rvim.plugin_loaded "vim-doge" then
      key_maps.v.D = "DOGe"
    end

    -- fterm
    if rvim.plugin_loaded "FTerm.nvim" then
      key_maps.e = rvim.wk.fterm
    end

    -- far
    if rvim.plugin_loaded "far.vim" then
      key_maps.F = rvim.wk.far
    end

    -- git_signs
    if rvim.plugin_loaded "gitsigns.nvim" then
      key_maps.h = rvim.wk.gitsigns
    end

    -- fugitive
    if rvim.plugin_loaded "vim-fugitive" then
      key_maps.g = rvim.wk.fugitive
    end

    -- kommentary
    if rvim.plugin.kommentary.active then
      key_maps["/"] = rvim.wk.kommentary["/"]
      key_maps.a["/"] = rvim.wk.kommentary.a["/"]
    end

    -- lsp
    if rvim.plugin_loaded "nvim-lspconfig" then
      key_maps.v = rvim.wk.lsp
      key_maps.L = rvim.wk.lsp_utils
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

    -- matchup
    if rvim.plugin.matchup.active then
      key_maps.v.W = "where am i"
    end

    -- osv
    if rvim.plugin_loaded "one-small-step-for-vimkind" then
      key_maps.d.E = "osv run this"
      key_maps.d.l = "osv launch"
    end

    -- packer
    if rvim.plugin.packer.active then
      key_maps.E = rvim.wk.packer
    end

    -- playground
    if rvim.plugin.playground.active then
      key_maps.a.I = { ":TSPlaygroundToggle", "toggle ts playground" }
      if rvim.plugin_loaded "playground" then
        key_maps.a.E = "Inspect token"
      end
    end

    -- slide
    if vim.bo.ft == "slide" then
      key_maps["↵"] = "execute commnd"
      key_maps.A = rvim.wk.slide
      key_maps.b.l = "show all open buffers"
      key_maps.B = {
        name = "+Background",
        d = "dark",
        l = "light",
      }
    end

    -- snippets
    if rvim.plugin_loaded "vim-vsnip" then
      key_maps.c.s = "edit snippet"
    end

    -- tree
    if rvim.plugin_loaded "nvim-tree.lua" then
      key_maps.c.v = { ":NvimTreeToggle", "nvim-tree toggle" }
    end

    -- telescope
    if rvim.plugin.telescope.active then
      key_maps.f = {
        name = "+Telescope",
        b = rvim.wk.telescope.browser,
        c = rvim.wk.telescope.builtin,
        d = rvim.wk.telescope.dotfiles,
        f = rvim.wk.telescope.files,
        g = rvim.wk.telescope.git,
        h = rvim.wk.telescope.frecency,
        l = rvim.wk.telescope.live,
        r = rvim.wk.telescope.config,
        R = rvim.wk.telescope.oldfiles,
        v = rvim.wk.telescope.lsp,
        e = rvim.wk.telescope.tmux,
        x = rvim.wk.telescope.extensions,
      }
    end

    -- treesitter
    if rvim.plugin_loaded "nvim-treesitter" then
      key_maps.I.e = { ":TSInstallInfo", "ts info" }
      key_maps.I.u = { ":TSUpdate", "ts update" }
    end

    -- trouble
    if rvim.plugin_loaded "trouble.nvim" then
      key_maps.v.x = rvim.wk.trouble
    end

    -- undotree
    if rvim.plugin_loaded "undotree" then
      key_maps.a.u = { ":UndotreeToggle", "toggle undotree" }
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
