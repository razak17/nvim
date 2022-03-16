local tools = {}

rvim.plugins.tools = {
  fterm = { active = true },
  far = { active = true },
  bookmarks = { active = false },
  undotree = { active = true },
  project = { active = true },
  diffview = { active = false },
  structlog = { active = true },
  bbye = { active = true },
  neoclip = { active = true },
  auto_session = { active = true },
  impatient = { active = true },
  hop = { active = true },
  telescope = { active = true },
  telescope_fzf = { active = true },
  telescope_ui_select = { active = true },
  telescope_tmux = { active = true },
  telescope_frecency = { active = true },
  telescope_dap = { active = true },
  telescope_file_browser = { active = true },
  -- TODO: handle these later
  glow = { active = false },
  doge = { active = false },
  dadbod = { active = false },
  restconsole = { active = false },
  markdown_preview = { active = true },
}

local utils = require "user.utils"

tools["sindrets/diffview.nvim"] = {
  event = "BufReadPre",
  config = utils.load_conf("tools", "diff_view"),
  disable = not rvim.plugins.tools.diffview.active,
}

tools["mbbill/undotree"] = {
  config = function()
    vim.g.undotree_TreeNodeShape = "◦" -- Alternative: '◉'
    vim.g.undotree_SetFocusWhenToggle = 1
    require("which-key").register {
      ["<leader>u"] = { ":UndotreeToggle<cr>", "toggle undotree" },
    }
  end,
  disable = not rvim.plugins.tools.undotree.active,
}

tools["ahmedkhalf/project.nvim"] = {
  config = utils.load_conf("tools", "project"),
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

    require("which-key").register {
      ["<leader>lD"] = "DOGe",
    }
  end,
  disable = not rvim.plugins.tools.doge.active,
}

tools["numToStr/FTerm.nvim"] = {
  event = { "BufWinEnter" },
  config = function()
    function _G.__fterm_cmd(key)
      local term = require "FTerm"
      local cmd = term:new { cmd = "gitui" }
      if key == "node" then
        cmd = term:new { cmd = "node" }
      elseif key == "python" then
        cmd = term:new { cmd = "python" }
      elseif key == "lazygit" then
        cmd = term:new { cmd = "lazygit" }
      elseif key == "ranger" then
        cmd = term:new { cmd = "ranger" }
      end
      cmd:toggle()
    end
    -- rvim.nnoremap("<F12>", '<cmd>lua require("FTerm").toggle()<CR>')
    rvim.tnoremap("<F12>", '<C-\\><C-n><cmd>lua require("FTerm").toggle()<CR>')

    require("which-key").register {
      ["<F12>"] = {
        '<cmd>lua require("FTerm").toggle()<CR>',
        "toggle term",
      },
      ["<leader>t"] = {
        name = "+Fterm",
        [";"] = { '<cmd>lua require("FTerm").open()<cr>', "new" },
        l = { ':lua _G.__fterm_cmd("lazygit")<cr>', "lazygit" },
        n = { ':lua _G.__fterm_cmd("node")<cr>', "node" },
        p = { ':lua _G.__fterm_cmd("python")<cr>', "python" },
        r = { ":lua _G.__fterm_cmd(ranger)<cr>", "ranger" },
      },
    }
  end,
  disable = not rvim.plugins.tools.fterm.active,
}

tools["MattesGroeger/vim-bookmarks"] = {
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.g.bookmark_no_default_key_mappings = 1
    vim.g.bookmark_sign = ""
    require("which-key").register {
      ["<leader>m"] = {
        name = "+Mark",
        t = { ":BookmarkToggle<cr>", "toggle" },
        p = { ":BookmarkPrev<cr>", "previous mark" },
        n = { ":BookmarkNext<cr>", "next mark" },
      },
    }
  end,
  disable = not rvim.plugins.tools.bookmarks.active,
}

tools["diepm/vim-rest-console"] = {
  event = "VimEnter",
  disable = not rvim.plugins.tools.restconsole.active,
}

tools["iamcco/markdown-preview.nvim"] = {
  run = "cd app & yarn install",
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
    require("which-key").register {
      ["<leader>Ff"] = { ":Farr --source=vimgrep<cr>", "far: replace in File" },
      ["<leader>Fd"] = { ":Fardo<cr>", "far: do" },
      ["<leader>Fi"] = { ":Farf<cr>", "far: search iteratively" },
      ["<leader>Fr"] = { ":Farr --source=rgnvim<cr>", "far: replace in project" },
      ["<leader>Fu"] = { ":Farundo<cr>", "far: undo" },
    }
  end,
  disable = not rvim.plugins.tools.far.active,
}

tools["Tastyep/structlog.nvim"] = {
  disable = not rvim.plugins.tools.structlog.active,
}

tools["AckslD/nvim-neoclip.lua"] = {
  config = function()
    require("neoclip").setup {
      enable_persistent_history = true,
      keys = {
        telescope = {
          i = { select = "<c-p>", paste = "<CR>", paste_behind = "<c-k>" },
          n = { select = "p", paste = "<CR>", paste_behind = "P" },
        },
      },
    }
    local function clip()
      require("telescope").extensions.neoclip.default(require("telescope.themes").get_dropdown())
    end
    require("which-key").register {
      ["<leader>fN"] = { clip, "neoclip: open yank history" },
    }
  end,
  disable = not rvim.plugins.tools.neoclip.active,
}

tools["nvim-telescope/telescope.nvim"] = {
  config = utils.load_conf("tools", "telescope"),
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

tools["tami5/sqlite.lua"] = { disable = not rvim.plugins.tools.telescope_frecency.active }

tools["nvim-telescope/telescope-frecency.nvim"] = {
  disable = not rvim.plugins.tools.telescope_frecency.active,
}

tools["nvim-telescope/telescope-dap.nvim"] = {
  disable = not rvim.plugins.tools.telescope_dap.active,
}

tools["nvim-telescope/telescope-file-browser.nvim"] = {
  disable = not rvim.plugins.tools.telescope_file_browser.active,
}

tools["rmagatti/auto-session"] = {
  config = function()
    require("auto-session").setup {
      log_level = "error",
      auto_session_root_dir = join_paths(rvim.get_cache_dir(), "session/auto/"),
    }

    require("which-key").register {
      ["<leader>s"] = {
        name = "+Session",
        l = { ":RestoreSession<cr>", "restore" },
        s = { ":SaveSession<cr>", "save" },
      },
    }
  end,
  disable = not rvim.plugins.tools.auto_session.active,
}

tools["phaazon/hop.nvim"] = {
  keys = { { "n", "s" }, "f", "F" },
  config = function()
    local hop = require "hop"
    -- remove h,j,k,l from hops list of keys
    hop.setup { keys = "etovxqpdygfbzcisuran" }
    rvim.nnoremap("s", hop.hint_char1)
    rvim.nnoremap("s", function()
      hop.hint_char1 { multi_windows = true }
    end)
    -- NOTE: override F/f using hop motions
    vim.keymap.set({ "x", "n" }, "F", function()
      hop.hint_char1 {
        direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
        current_line_only = true,
        inclusive_jump = false,
      }
    end)
    vim.keymap.set({ "x", "n" }, "f", function()
      hop.hint_char1 {
        direction = require("hop.hint").HintDirection.AFTER_CURSOR,
        current_line_only = true,
        inclusive_jump = false,
      }
    end)
    rvim.onoremap("F", function()
      hop.hint_char1 {
        direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
        current_line_only = true,
        inclusive_jump = true,
      }
    end)
    rvim.onoremap("f", function()
      hop.hint_char1 {
        direction = require("hop.hint").HintDirection.AFTER_CURSOR,
        current_line_only = true,
        inclusive_jump = true,
      }
    end)
  end,
  disable = not rvim.plugins.tools.hop.active,
}

tools["lewis6991/impatient.nvim"] = {
  disable = not rvim.plugins.tools.impatient.active,
}

tools["moll/vim-bbye"] = {
  config = function()
    require("which-key").register {
      ["<leader>c"] = { ":Bdelete<cr>", "close buffer" },
      ["<leader>bx"] = { ":bufdo :Bdelete<cr>", "close all buffers" },
      ["<leader>q"] = { "<Cmd>Bwipeout<CR>", "wipe buffer" },
    }
  end,
  disable = not rvim.plugins.tools.bbye.active,
}

return tools
