local tools = {}

rvim.plugins.tools = {}

local plug_utils = require("user.utils.plugins")
local conf = require("user.utils").load_conf
local module = "tools"

local enabled = {
  "fterm",
  "far",
  "undotree",
  "project",
  "bbye",
  "structlog",
  "neoclip",
  "auto_session",
  "impatient",
  "hop",
  "telescope",
  "telescope_fzf",
  "telescope_ui_select",
  "telescope_media_files",
  "telescope_dap",
  "telescope_file_browser",
  "telescope_zoxide",
  "mru",
  "markdown_preview",
  "apathy",
  "projectionist",
  "plenary",
  "popup",
  "rest",
  "sniprun",
  "neotest",
  "howdoi",
  "inc_rename",
  "line_diff",
  "cheat_sheet",
  "navic",
  "diffview",
  "neorg",
}
plug_utils.enable_plugins(module, enabled)

local disabled = {
  -- TODO: handle these later
  "package_info",
  "glow",
  "doge",
  "dadbod",
  "restconsole",
}
plug_utils.disable_plugins(module, disabled)

tools["sindrets/diffview.nvim"] = {
  event = "BufReadPre",
  setup = function()
    rvim.nnoremap("<localleader>gd", "<Cmd>DiffviewOpen<CR>", "diffview: diff HEAD")
    rvim.nnoremap("<localleader>gh", "<Cmd>DiffviewFileHistory<CR>", "diffview: file history")
  end,
  config = conf(module, "diffview"),
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
  config = conf(module, "project"),
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
  config = conf(module, "fterm"),
  disable = not rvim.plugins.tools.fterm.active,
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
      require("telescope").extensions.neoclip.default(rvim.telescope.dropdown())
    end

    require("which-key").register({
      ["<leader>fN"] = { clip, "neoclip: open yank history" },
    })
  end,
  disable = not rvim.plugins.tools.neoclip.active,
}

tools["nvim-telescope/telescope.nvim"] = {
  config = conf(module, "telescope"),
  disable = not rvim.plugins.tools.telescope.active,
}

tools["nvim-telescope/telescope-fzf-native.nvim"] = {
  run = "make",
  disable = not rvim.plugins.tools.telescope_fzf.active,
}

tools["tami5/sqlite.lua"] = {
  disable = not rvim.plugins.tools.telescope.active,
}

tools["ilAYAli/scMRU.nvim"] = {
  disable = not rvim.plugins.tools.mru.active,
}

tools["nvim-telescope/telescope-ui-select.nvim"] = {
  disable = not rvim.plugins.tools.telescope_ui_select.active,
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
  branch = "v1",
  keys = { { "n", "s" }, "f", "F" },
  config = conf(module, "hop"),
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

tools["tpope/vim-apathy"] = {
  disable = not rvim.plugins.tools.apathy.active,
}

tools["tpope/vim-projectionist"] = {
  config = conf(module, "vim-projectionist"),
  disable = not rvim.plugins.tools.projectionist.active,
}

tools["nvim-lua/plenary.nvim"] = { disable = not rvim.plugins.tools.plenary.active }

tools["nvim-lua/popup.nvim"] = { disable = not rvim.plugins.tools.popup.active }

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
  config = conf(module, "sniprun"),
  run = "bash ./install.sh",
  disable = not rvim.plugins.tools.sniprun.active,
}

tools["vuki656/package-info.nvim"] = {
  event = "BufWinEnter",
  ft = { "json" },
  config = conf(module, "package-info"),
  requires = "MunifTanjim/nui.nvim",
  disable = not rvim.plugins.tools.package_info.active,
}

tools["nvim-neotest/neotest"] = {
  config = conf(module, "neotest"),
  requires = {
    "rcarriga/neotest-plenary",
    "rcarriga/neotest-vim-test",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "antoinemadec/FixCursorHold.nvim",
  },
  disable = not rvim.plugins.tools.neotest.active,
}

tools["Zane-/howdoi.nvim"] = {
  disable = not rvim.plugins.tools.howdoi.active,
}

tools["smjonas/inc-rename.nvim"] = {
  config = function()
    require("inc_rename").setup({
      hl_group = "Visual",
    })
    vim.keymap.set("n", "<leader>rn", function()
      return ":IncRename " .. vim.fn.expand("<cword>")
    end, { expr = true, silent = false, desc = "lsp: incremental rename" })
  end,
  disable = not rvim.plugins.tools.inc_rename.active,
}

tools["AndrewRadev/linediff.vim"] = {
  cmd = "Linediff",
  disable = not rvim.plugins.tools.line_diff.active,
}

tools["Djancyp/cheat-sheet"] = {
  config = function()
    require("cheat-sheet").setup({
      auto_fill = {
        current_word = false,
      },
      main_win = {
        border = "single",
      },
      input_win = {
        border = "single",
      },
    })
    rvim.nnoremap("<localleader>s", ":CheatSH<CR>", "cheat-sheet")
  end,
  disable = not rvim.plugins.tools.cheat_sheet.active,
}

tools["SmiteshP/nvim-navic"] = {
  requires = "neovim/nvim-lspconfig",
  config = function()
    vim.g.navic_silence = true
    local highlights = require("user.utils.highlights")
    local s = rvim.style
    local misc = s.icons.misc

    highlights.set_hl("NavicText", { bold = false })
    highlights.set_hl("NavicSeparator", { link = "Directory" })
    local icons = rvim.map(function(icon, key)
      highlights.set_hl(("NavicIcons%s"):format(key), { link = rvim.lsp.kind_highlights[key] })
      return icon .. " "
    end, s.codicons.kind)

    require("nvim-navic").setup({
      icons = icons,
      highlight = true,
      depth_limit_indicator = misc.ellipsis,
      separator = (" %s "):format(misc.arrow_right),
    })
  end,
  disable = not rvim.plugins.tools.navic.active,
}

tools["vhyrro/neorg"] = {
  requires = { "vhyrro/neorg-telescope" },
  config = conf(module, "neorg"),
  disable = not rvim.plugins.tools.neorg.active,
}

return tools
