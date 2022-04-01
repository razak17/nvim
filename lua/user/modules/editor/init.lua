local editor = {}

rvim.plugins.editor = {
  ajk = { active = true },
  easy_align = { active = true },
  cool = { active = true },
  surround = { active = true },
  colorizer = { active = true },
  kommentary = { active = true },
  dial = { active = true },
  fold_cycle = { active = false },
  cursorword = { active = false },
  surround_funk = { active = true },
  better_diagraphs = { active = false },
  tabout = { active = true },
  marks = { active = true },
  vim_uppercase_sql = { active = true },
}

editor["xiyaowong/accelerated-jk.nvim"] = {
  event = { "BufWinEnter" },
  config = function()
    require("accelerated-jk").setup {
      mappings = { j = "gj", k = "gk" },
      -- If the interval of key-repeat takes more than `acceleration_limit` ms, the step is reset
      -- acceleration_limit = 150,
    }
  end,
  disable = not rvim.plugins.editor.ajk.active,
}

editor["tpope/vim-surround"] = {
  config = function()
    rvim.xmap("S", "<Plug>VSurround")
    rvim.xmap("S", "<Plug>VSurround")
  end,
  disable = not rvim.plugins.editor.surround.active,
}

editor["monaqa/dial.nvim"] = {
  event = { "BufWinEnter" },
  config = function()
    local dial = require "dial.map"
    local augend = require "dial.augend"
    local map = vim.keymap.set
    map("n", "<C-a>", dial.inc_normal(), { remap = false })
    map("n", "<C-x>", dial.dec_normal(), { remap = false })
    map("v", "<C-a>", dial.inc_visual(), { remap = false })
    map("v", "<C-x>", dial.dec_visual(), { remap = false })
    map("v", "g<C-a>", dial.inc_gvisual(), { remap = false })
    map("v", "g<C-x>", dial.dec_gvisual(), { remap = false })

    require("dial.config").augends:register_group {
      -- default augends used when no group name is specified
      default = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.date.alias["%Y/%m/%d"],
        augend.constant.alias.bool,
        augend.constant.new {
          elements = { "&&", "||" },
          word = false,
          cyclic = true,
        },
      },
      dep_files = {
        augend.semver.alias.semver,
      },
    }

    rvim.augroup("DialMaps", {
      {
        event = "FileType",
        pattern = { "yaml", "toml" },
        command = function()
          map("n", "<C-a>", require("dial.map").inc_normal "dep_files", { remap = true })
        end,
      },
    })
  end,
  disable = not rvim.plugins.editor.dial.active,
}

editor["junegunn/vim-easy-align"] = {
  config = function()
    rvim.nmap("ga", "<Plug>(EasyAlign)")
    rvim.xmap("ga", "<Plug>(EasyAlign)")
    rvim.vmap("<Enter>", "<Plug>(EasyAlign)")
  end,
  event = { "BufReadPre", "BufNewFile" },
  disable = not rvim.plugins.editor.easy_align.active,
}

editor["xiyaowong/nvim-cursorword"] = {
  event = { "InsertEnter" },
  config = function()
    vim.cmd [[hi! CursorWord cterm=NONE gui=NONE guibg=#3f444a]]
  end,
  disable = not rvim.plugins.editor.cursorword.active,
}

editor["norcalli/nvim-colorizer.lua"] = {
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("colorizer").setup({
      "*",
      css = { rgb_fn = true, hsl_fn = true, names = true },
      scss = { rgb_fn = true, hsl_fn = true, names = true },
      sass = { rgb_fn = true, names = true },
      vim = { names = true },
      html = { mode = "foreground" },
    }, {
      names = false,
      mode = "background",
    })
  end,
  disable = not rvim.plugins.editor.colorizer.active,
}

editor["romainl/vim-cool"] = {
  config = function()
    vim.g.CoolTotalMatches = 1
  end,
  disable = not rvim.plugins.editor.cool.active,
}

editor["jghauser/fold-cycle.nvim"] = {
  config = function()
    require("fold-cycle").setup()
    rvim.nnoremap("<BS>", function()
      require("fold-cycle").open()
    end)
  end,
  disable = not rvim.plugins.editor.fold_cycle.active,
}

editor["b3nj5m1n/kommentary"] = {
  event = { "BufWinEnter" },
  config = function()
    require("kommentary.config").configure_language(
      "default",
      { prefer_single_line_comments = true }
    )
    local fts = { "zsh", "sh", "yaml", "vim" }
    for _, f in pairs(fts) do
      if f == "vim" then
        require("kommentary.config").configure_language(f, { single_line_comment_string = '"' })
      else
        require("kommentary.config").configure_language(f, { single_line_comment_string = "#" })
      end
    end

    rvim.xmap("<leader>/", "<Plug>kommentary_visual_default")

    require("which-key").register {
      ["<leader>/"] = { "<Plug>kommentary_line_default", "comment" },
      ["<leader>a/"] = { "<Plug>kommentary_motion_default", "comment motion default" },
    }
  end,
  disable = not rvim.plugins.editor.kommentary.active,
}

editor["Matt-A-Bennett/vim-surround-funk"] = {
  config = function()
    vim.g.surround_funk_create_mappings = 0
    local map = vim.keymap.set
    -- operator pending mode: grip surround
    map({ "n", "v" }, "gs", "<Plug>(GripSurroundObject)")
    map({ "n", "v" }, "gS", "<Plug>(GripSurroundObjectNoPaste)")
    map({ "o", "x" }, "sF", "<Plug>(SelectWholeFUNCTION)")
    require("which-key").register {
      ["<leader>r"] = {
        name = "+dsf: delete",
        s = {
          F = { "<Plug>(DeleteSurroundingFunction)", "delete surrounding function" },
          f = { "<Plug>(DeleteSurroundingFUNCTION)", "delete surrounding outer function" },
        },
      },
      ["<leader>C"] = {
        name = "+dsf: change",
        s = {
          F = { "<Plug>(ChangeSurroundingFunction)", "change surrounding function" },
          f = { "<Plug>(ChangeSurroundingFUNCTION)", "change outer surrounding function" },
        },
      },
    }
  end,
  disable = not rvim.plugins.editor.surround_funk.active,
}

-- CR not working properly
editor["protex/better-digraphs.nvim"] = {
  keys = { { "i", "<C-k><C-k>" } },
  config = function()
    rvim.inoremap("<C-k><C-k>", function()
      require("betterdigraphs").digraphs "i"
    end)
    rvim.nnoremap("r<C-k><C-k>", function()
      require("betterdigraphs").digraphs "r"
    end)
    rvim.vnoremap("r<C-k><C-k>", function()
      require("betterdigraphs").digraphs "gvr"
    end)
  end,
  disable = not rvim.plugins.editor.better_diagraphs.active,
}

editor["danymat/neogen"] = {
  setup = function()
    require("which-key").register {
      ["<localleader>nc"] = "comment: generate",
    }
  end,
  keys = { "<localleader>nc" },
  requires = "nvim-treesitter/nvim-treesitter",
  config = function()
    require("neogen").setup { snippet_engine = "luasnip" }
    rvim.nnoremap("<localleader>nc", require("neogen").generate, "comment: generate")
  end,
}

editor["abecodes/tabout.nvim"] = {
  wants = { "nvim-treesitter" },
  after = { "nvim-cmp" },
  config = function()
    require("tabout").setup {
      completion = false,
      ignore_beginning = false,
    }
  end,
  disable = not rvim.plugins.editor.tabout.active,
}

editor["chentau/marks.nvim"] = {
  config = function()
    require("zephyr.util").plugin("marks", { "MarkSignHL", { foreground = "Red" } })
    require("which-key").register({
      m = {
        name = "marks",
        b = { "<Cmd>MarksListBuf<CR>", "list buffer" },
        g = { "<Cmd>MarksQFListGlobal<CR>", "list global" },
        ["0"] = { "<Cmd>BookmarksQFList 0<CR>", "list bookmark" },
      },
    }, {
      prefix = "<leader>",
    })
    require("marks").setup {
      builtin_marks = { "." },
      bookmark_0 = {
        sign = "⚑",
        virt_text = "bookmarks",
      },
    }
  end,
  disable = not rvim.plugins.editor.marks.active,
}

editor["jsborjesson/vim-uppercase-sql"] = {
  disable = not rvim.plugins.editor.vim_uppercase_sql.active,
}

return editor
