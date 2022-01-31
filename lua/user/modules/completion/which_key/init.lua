return function()
  rvim.which_key = {
    setup = {
      plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        presets = {
          operators = false, -- adds help for operators like d, y, ...
          motions = false, -- adds help for motions
          text_objects = false, -- help for text objects triggered after entering an operator
          windows = true, -- default bindings on <c-w>
          nav = true, -- misc bindings to work with windows
          z = true, -- bindings for folds, spelling and others prefixed with z
          g = true, -- bindings for prefixed with g
        },
        spelling = { enabled = true, suggestions = 20 }, -- use which-key for spelling hints
      },
      icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
      },
      window = {
        border = "single", -- none, single, double, shadow
        position = "bottom", -- bottom, top
        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
      },
      layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
      },
      hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
      show_help = true, -- show help message on the command line when the popup is visible
    },

    opts = {
      mode = "n", -- NORMAL mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    },
    vopts = {
      mode = "v", -- VISUAL mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    },
    -- NOTE: Prefer using : over <cmd> as the latter avoids going back in normal-mode.
    -- see https://neovim.io/doc/user/map.html#:map-cmd
    vmappings = {},
    mappings = {},
  }

  local which_key = require "which-key"

  which_key.setup(rvim.which_key.setup)

  _G.WhichKey = {}

  -- Set default keymaps
  vim.g.which_key_map = rvim.wk.keymaps.defaults

  -- plugin keymaps
  WhichKey.SetKeyOnFT = function()
    -- Get Which-Key keymap
    local key_maps = vim.g.which_key_map

    -- bookmarks
    if rvim.plugin.bufferline.active then
      key_maps.b.h = "move left"
      key_maps.b.l = "move right"
    end

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

    -- DOGE
    if rvim.plugin_loaded "vim-doge" then
      key_maps.v.D = "DOGe"
    end

    -- fterm
    if rvim.plugin_loaded "FTerm.nvim" then
      key_maps.t = rvim.wk.fterm
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
      key_maps.l = rvim.wk.lsp
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
      key_maps.p = rvim.wk.packer
    end

    -- playground
    if rvim.plugin.playground.active then
      key_maps.a.I = { ":TSPlaygroundToggle", "toggle playground" }
      key_maps.a.E = "Inspect token"
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
      key_maps.S = "edit snippet"
    end

    -- tree
    if rvim.plugin_loaded "nvim-tree.lua" then
      key_maps.e = "nvim-tree toggle"
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

    -- Register keymaps
    local opts = rvim.which_key.opts
    local vopts = rvim.which_key.vopts

    -- local vmappings = rvim.which_key.vmappings

    which_key.register(key_maps, opts)
    -- which_key.register(vmappings, vopts)
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
