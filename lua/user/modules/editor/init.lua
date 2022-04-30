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
  vim_dirtytalk = { active = true },
}

local load_conf = require("user.utils").load_conf

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
  event = "BufWinEnter",
  config = function()
    rvim.xmap("S", "<Plug>VSurround")
    rvim.xmap("S", "<Plug>VSurround")
  end,
  disable = not rvim.plugins.editor.surround.active,
}

editor["monaqa/dial.nvim"] = {
  event = { "BufWinEnter" },
  config = load_conf("editor", "dial"),
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
  event = { "BufWinEnter" },
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
  event = "BufWinEnter",
  config = load_conf("editor", "vim-surround-funk"),
  disable = not rvim.plugins.editor.surround_funk.active,
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
  event = { "BufWinEnter" },
  config = load_conf("editor", "marks"),
  disable = not rvim.plugins.editor.marks.active,
}

editor["jsborjesson/vim-uppercase-sql"] = {
  event = "InsertEnter",
  ft = { "sql" },
  disable = not rvim.plugins.editor.vim_uppercase_sql.active,
}

editor["psliwka/vim-dirtytalk"] = {
  run = ":DirtytalkUpdate",
  disable = not rvim.plugins.editor.vim_dirtytalk.active,
}

return editor
