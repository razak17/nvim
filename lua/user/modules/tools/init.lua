local tools = {}

rvim.plugins.tools = {
  fterm = { active = true },
  far = { active = true },
  bookmarks = { active = false }, --j
  undotree = { active = true },
  project = { active = true },
  diffview = { active = false }, --j
  bbye = { active = true },
  structlog = { active = true },
  neoclip = { active = true },
  auto_session = { active = true },
  impatient = { active = true },
  hop = { active = true },
  telescope = { active = true },
  telescope_fzf = { active = true },
  telescope_ui_select = { active = true },
  telescope_tmux = { active = false },
  telescope_media_files = { active = true },
  telescope_dap = { active = true },
  telescope_file_browser = { active = true },
  telescope_frecency = { active = true },
  telescope_zoxide = { active = true },
  markdown_preview = { active = true },
  apathy = { active = true },
  todo_comments = { active = true },
  projectionist = { active = true },
  plenary = { active = true },
  popup = { active = true },
  gps = { active = true },
  rest = { active = true },
  sniprun = { active = true },
  package_info = { active = true },
  -- TODO: handle these later
  glow = { active = false }, --j
  doge = { active = false }, --j
  dadbod = { active = false }, --j
  restconsole = { active = false }, --j
}

local conf = require("user.utils").load_conf

tools["sindrets/diffview.nvim"] = {
  event = "BufReadPre",
  setup = function()
    rvim.nnoremap("<localleader>gd", "<Cmd>DiffviewOpen<CR>", "diffview: diff HEAD")
  end,
  config = conf("tools", "diffview"),
  disable = not rvim.plugins.tools.diffview.active,
}

tools["mbbill/undotree"] = {
  event = "BufWinEnter",
  cmd = "UndotreeToggle",
  setup = function()
    rvim.nnoremap("<leader>u", "<cmd>UndotreeToggle<CR>", "undotree: toggle")
  end,
  config = function()
    vim.g.undotree_TreeNodeShape = "◦" -- Alternative: '◉'
    vim.g.undotree_SetFocusWhenToggle = 1
  end,
  disable = not rvim.plugins.tools.undotree.active,
}

tools["ahmedkhalf/project.nvim"] = {
  config = conf("tools", "project"),
  disable = not rvim.plugins.tools.project.active,
}

tools["npxbr/glow.nvim"] = {
  run = ":GlowInstall",
  branch = "main",
  disable = not rvim.plugins.tools.glow.active,
}

tools["kkoomen/vim-doge"] = {
  run = ":call doge#install()",
  config = function()
    vim.g.doge_mapping = "<Leader>lD"
  end,
  disable = not rvim.plugins.tools.doge.active,
}

tools["numToStr/FTerm.nvim"] = {
  event = { "BufWinEnter" },
  config = conf("tools", "fterm"),
  disable = not rvim.plugins.tools.fterm.active,
}

tools["MattesGroeger/vim-bookmarks"] = {
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.g.bookmark_no_default_key_mappings = 1
    vim.g.bookmark_sign = ""
    require("which-key").register({
      ["<leader>m"] = {
        name = "Mark",
        t = { ":BookmarkToggle<cr>", "toggle" },
        p = { ":BookmarkPrev<cr>", "previous mark" },
        n = { ":BookmarkNext<cr>", "next mark" },
      },
    })
  end,
  disable = not rvim.plugins.tools.bookmarks.active,
}

tools["diepm/vim-rest-console"] = {
  event = "VimEnter",
  disable = not rvim.plugins.tools.restconsole.active,
}

tools["iamcco/markdown-preview.nvim"] = {
  run = function()
    vim.fn["mkdp#util#install"]()
  end,
  ft = { "markdown" },
  config = function()
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
  end,
  disable = not rvim.plugins.tools.markdown_preview.active,
}

tools["brooth/far.vim"] = {
  event = { "BufRead" },
  config = function()
    vim.g["far#source"] = "rg"
    vim.g["far#enable_undo"] = 1
    require("which-key").register({
      ["<leader>Ff"] = { ":Farr --source=vimgrep<cr>", "far: replace in File" },
      ["<leader>Fd"] = { ":Fardo<cr>", "far: do" },
      ["<leader>Fi"] = { ":Farf<cr>", "far: search iteratively" },
      ["<leader>Fr"] = { ":Farr --source=rgnvim<cr>", "far: replace in project" },
      ["<leader>Fu"] = { ":Farundo<cr>", "far: undo" },
      ["<leader>FU"] = { ":UpdateRemotePlugins<cr>", "far: update remote" },
    })
  end,
  disable = not rvim.plugins.tools.far.active,
}

tools["Tastyep/structlog.nvim"] = {
  disable = not rvim.plugins.tools.structlog.active,
}

tools["AckslD/nvim-neoclip.lua"] = {
  config = function()
    require("neoclip").setup({
      enable_persistent_history = false,
      keys = {
        telescope = {
          i = { select = "<c-p>", paste = "<CR>", paste_behind = "<c-k>" },
          n = { select = "p", paste = "<CR>", paste_behind = "P" },
        },
      },
    })
    local function clip()
      require("telescope").extensions.neoclip.default(require("telescope.themes").get_dropdown())
    end

    require("which-key").register({
      ["<leader>fN"] = { clip, "neoclip: open yank history" },
    })
  end,
  disable = not rvim.plugins.tools.neoclip.active,
}

tools["nvim-telescope/telescope.nvim"] = {
  config = conf("tools", "telescope"),
  disable = not rvim.plugins.tools.telescope.active,
}

tools["nvim-telescope/telescope-fzf-native.nvim"] = {
  run = "make",
  disable = not rvim.plugins.tools.telescope_fzf.active,
}

tools["nvim-telescope/telescope-ui-select.nvim"] = {
  disable = not rvim.plugins.tools.telescope_ui_select.active,
}

tools["camgraff/telescope-tmux.nvim"] = {
  disable = not rvim.plugins.tools.telescope_ui_select.active,
}

tools["tami5/sqlite.lua"] = {
  disable = not rvim.plugins.tools.telescope_frecency.active,
}

tools["nvim-telescope/telescope-frecency.nvim"] = {
  disable = not rvim.plugins.tools.telescope_frecency.active,
}

tools["nvim-telescope/telescope-dap.nvim"] = {
  disable = not rvim.plugins.tools.telescope_dap.active,
}

tools["nvim-telescope/telescope-file-browser.nvim"] = {
  disable = not rvim.plugins.tools.telescope_file_browser.active,
}

tools["nvim-telescope/telescope-media-files.nvim"] = {
  disable = not rvim.plugins.tools.telescope_media_files.active,
}

tools["jvgrootveld/telescope-zoxide"] = {
  disable = not rvim.plugins.tools.telescope_zoxide.active,
}

tools["rmagatti/auto-session"] = {
  config = function()
    require("auto-session").setup({
      log_level = "error",
      auto_session_root_dir = join_paths(rvim.get_cache_dir(), "session/auto/"),
      auto_restore_enabled = false,
      auto_session_use_git_branch = false, -- This cause inconsistent results
    })
    require("which-key").register({
      ["<leader>sl"] = { ":RestoreSession<cr>", "auto-session: restore" },
      ["<leader>ss"] = { ":SaveSession<cr>", "auto-session: save" },
    })
  end,
  disable = not rvim.plugins.tools.auto_session.active,
}

tools["phaazon/hop.nvim"] = {
  keys = { { "n", "s" }, "f", "F" },
  config = conf("tools", "hop"),
  disable = not rvim.plugins.tools.hop.active,
}

tools["lewis6991/impatient.nvim"] = {
  disable = not rvim.plugins.tools.impatient.active,
}

tools["moll/vim-bbye"] = {
  event = "BufWinEnter",
  config = function()
    require("which-key").register({
      ["<leader>c"] = { ":Bdelete!<cr>", "close buffer" },
      ["<leader>bx"] = { ":bufdo :Bdelete<cr>", "close all buffers" },
      ["<leader>q"] = { "<Cmd>Bwipeout<CR>", "wipe buffer" },
    })
  end,
  disable = not rvim.plugins.tools.bbye.active,
}

tools["folke/todo-comments.nvim"] = {
  event = { "BufWinEnter" },
  requires = "nvim-lua/plenary.nvim",
  config = function()
    -- this plugin is not safe to reload
    if vim.g.packer_compiled_loaded then
      return
    end
    require("todo-comments").setup({
      highlight = {
        exclude = { "org", "orgagenda", "vimwiki", "markdown" },
      },
    })
    require("which-key").register({
      ["<leader>tt"] = {
        "<Cmd>TodoTrouble<CR>",
        "trouble: todos",
      },
      ["<leader>tf"] = {
        "<Cmd>TodoTelescope<CR>",
        "telescope: todos",
      },
    })
  end,
  disable = not rvim.plugins.tools.todo_comments.active,
}

tools["tpope/vim-apathy"] = {
  disable = not rvim.plugins.tools.apathy.active,
}

tools["tpope/vim-projectionist"] = {
  config = conf("tools", "vim-projectionist"),
  disable = not rvim.plugins.tools.projectionist.active,
}

tools["nvim-lua/plenary.nvim"] = { disable = not rvim.plugins.tools.plenary.active }

tools["nvim-lua/popup.nvim"] = { disable = not rvim.plugins.tools.popup.active }

tools["SmiteshP/nvim-gps"] = {
  requires = "nvim-treesitter/nvim-treesitter",
  config = function()
    local icons = rvim.style.icons.kind
    require("nvim-gps").setup({
      separator = " " .. rvim.style.icons.misc.chevron_right .. " ",
      depth = 0,
      depth_limit_indicator = rvim.style.icons.misc.ellipsis,
      text_hl = "LineNr",
      icons = {
        ["class-name"] = icons.Class,
        ["function-name"] = icons.Function,
        ["container-name"] = icons.Module,
        ["tag-name"] = icons.Field,
        ["array-name"] = icons.Value,
        ["object-name"] = icons.Value,
      },
    })
  end,
  disable = not rvim.plugins.tools.gps.active,
}

tools["NTBBloodbath/rest.nvim"] = {
  requires = { "nvim-lua/plenary.nvim" },
  ft = { "http", "json" },
  config = function()
    require("rest-nvim").setup({
      -- Open request results in a horizontal split
      result_split_horizontal = true,
      -- Skip SSL verification, useful for unknown certificates
      skip_ssl_verification = true,
      -- Jump to request line on run
      jump_to_request = false,
      custom_dynamic_variables = {},
    })

    rvim.nnoremap("<leader>rr", "<Plug>RestNvim", "rest: run")
    rvim.nnoremap("<leader>rp", "<Plug>RestNvimPreview", "rest: run")
    rvim.nnoremap("<leader>rl", "<Plug>RestNvimLast", "rest: run")
  end,
  disable = not rvim.plugins.tools.rest.active,
}

tools["michaelb/sniprun"] = {
  event = "BufWinEnter",
  config = conf("tools", "sniprun"),
  run = "bash ./install.sh",
  disable = not rvim.plugins.tools.sniprun.active,
}

tools["vuki656/package-info.nvim"] = {
  event = "BufWinEnter",
  ft = { "json" },
  config = conf("tools", "package-info"),
  requires = "MunifTanjim/nui.nvim",
  disable = not rvim.plugins.tools.package_info.active,
}

return tools
