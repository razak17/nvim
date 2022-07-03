local conf = require("user.utils").load_conf

local editor = {}

editor["xiyaowong/accelerated-jk.nvim"] = {
  event = { "BufWinEnter" },
  config = function()
    require("accelerated-jk").setup({
      mappings = { j = "gj", k = "gk" },
      -- If the interval of key-repeat takes more than `acceleration_limit` ms, the step is reset
      -- acceleration_limit = 150,
    })
  end,
}

editor["tpope/vim-surround"] = {
  event = "BufWinEnter",
  config = function()
    rvim.xmap("S", "<Plug>VSurround")
    rvim.xmap("S", "<Plug>VSurround")
  end,
}

editor["monaqa/dial.nvim"] = {
  event = { "BufWinEnter" },
  config = conf("editor", "dial"),
}

editor["junegunn/vim-easy-align"] = {
  config = function()
    rvim.nmap("ga", "<Plug>(EasyAlign)")
    rvim.xmap("ga", "<Plug>(EasyAlign)")
    rvim.vmap("<Enter>", "<Plug>(EasyAlign)")
  end,
  event = { "BufReadPre", "BufNewFile" },
}

editor["xiyaowong/nvim-cursorword"] = {
  event = { "InsertEnter" },
  config = function()
    vim.cmd([[hi! CursorWord cterm=NONE gui=NONE guibg=#3f444a]])
  end,
  disable = true,
}

editor["norcalli/nvim-colorizer.lua"] = {
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("colorizer").setup({ "lua", "css", "vim", "kitty", "conf" }, {
      css = { rgb_fn = true, hsl_fn = true, names = true },
      scss = { rgb_fn = true, hsl_fn = true, names = true },
      sass = { rgb_fn = true, names = true },
      vim = { names = true },
      html = { mode = "foreground" },
    }, {
      RGB = false,
      names = false,
      mode = "background",
    })
  end,
}

editor["romainl/vim-cool"] = {
  event = { "BufWinEnter" },
  config = function()
    vim.g.CoolTotalMatches = 1
  end,
}

editor["jghauser/fold-cycle.nvim"] = {
  config = function()
    require("fold-cycle").setup()
    rvim.nnoremap("<BS>", function()
      require("fold-cycle").open()
    end)
  end,
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

    require("which-key").register({
      ["<leader>/"] = { "<Plug>kommentary_line_default", "comment" },
      ["<leader>a/"] = { "<Plug>kommentary_motion_default", "comment motion default" },
    })
  end,
}

editor["Matt-A-Bennett/vim-surround-funk"] = {
  event = "BufWinEnter",
  config = conf("editor", "vim-surround-funk"),
}

editor["danymat/neogen"] = {
  setup = function()
    rvim.nnoremap("<localleader>lc", require("neogen").generate, "comment: generate")
  end,
  keys = { "<localleader>lc" },
  requires = "nvim-treesitter/nvim-treesitter",
  module = "neogen",
  config = function()
    require("neogen").setup({ snippet_engine = "luasnip" })
  end,
}

editor["abecodes/tabout.nvim"] = {
  wants = { "nvim-treesitter" },
  after = { "nvim-cmp" },
  config = function()
    require("tabout").setup({
      completion = false,
      ignore_beginning = false,
    })
  end,
}

editor["chentoast/marks.nvim"] = {
  event = { "BufWinEnter" },
  config = conf("editor", "marks"),
}

editor["jsborjesson/vim-uppercase-sql"] = {
  event = "InsertEnter",
  ft = { "sql" },
}

editor["psliwka/vim-dirtytalk"] = {
  run = ":DirtytalkUpdate",
}

return editor
