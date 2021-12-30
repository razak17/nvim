local editor = {}

local utils = require "user.utils"

editor["xiyaowong/accelerated-jk.nvim"] = {
  event = { "BufWinEnter" },
  config = utils.load_conf("editor", "ajk"),
  disable = not rvim.plugin.ajk.active,
}

editor["tpope/vim-surround"] = {
  disable = not rvim.plugin.surround.active,
}

editor["monaqa/dial.nvim"] = {
  event = { "BufWinEnter" },
  disable = not rvim.plugin.dial.active,
}

editor["junegunn/vim-easy-align"] = {
  event = { "BufReadPre", "BufNewFile" },
  disable = not rvim.plugin.easy_align.active,
}

editor["xiyaowong/nvim-cursorword"] = {
  event = { "InsertEnter" },
  config = function()
    vim.cmd [[hi! CursorWord cterm=NONE gui=NONE guibg=#3f444a]]
  end,
  disable = not rvim.plugin.cursorword.active,
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
  disable = not rvim.plugin.colorizer.active,
}

editor["romainl/vim-cool"] = {
  config = function()
    vim.g.CoolTotalMatches = 1
  end,
  disable = not rvim.plugin.cool.active,
}

editor["arecarn/vim-fold-cycle"] = {
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.g.fold_cycle_default_mapping = 0
    vim.g.fold_cycle_toggle_max_open = 0
    vim.g.fold_cycle_toggle_max_close = 0
    local nmap = rvim.nmap
    nmap("<BS>", "<Plug>(fold-cycle-close)")
  end,
  disable = not rvim.plugin.fold_cycle.active,
}

editor["b3nj5m1n/kommentary"] = {
  event = { "BufWinEnter" },
  config = utils.load_conf("editor", "kommentary"),
  disable = not rvim.plugin.kommentary.active,
}

return editor
