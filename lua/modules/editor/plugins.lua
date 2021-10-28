local editor = {}

local utils = require "utils"

editor["xiyaowong/accelerated-jk.nvim"] = {
  opt = true,
  event = { "BufWinEnter" },
  config = utils.load_conf("editor", "ajk"),
  disable = not rvim.plugin.ajk.active,
}

editor["tpope/vim-surround"] = {
  config = function()
    local xmap = rvim.xmap
    xmap("S", "<Plug>VSurround")
    xmap("S", "<Plug>VSurround")
  end,
  disable = not rvim.plugin.surround.active,
}

editor["monaqa/dial.nvim"] = {
  event = { "BufWinEnter" },
  config = function()
    vim.cmd [[
      nmap <C-a> <Plug>(dial-increment)
      nmap <C-x> <Plug>(dial-decrement)
      vmap <C-a> <Plug>(dial-increment)
      vmap <C-x> <Plug>(dial-decrement)
      vmap g<C-a> <Plug>(dial-increment-additional)
      vmap g<C-x> <Plug>(dial-decrement-additional)
    ]]
  end,
  disable = not rvim.plugin.dial.active,
}

editor["junegunn/vim-easy-align"] = {
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local nmap = rvim.nmap
    local xmap = rvim.xmap
    local vmap = rvim.vmap
    vmap("<Enter>", "<Plug>(EasyAlign)")
    nmap("ga", "<Plug>(EasyAlign)")
    xmap("ga", "<Plug>(EasyAlign)")
  end,
  disable = not rvim.plugin.easy_align.active,
}

editor["razak17/vim-cursorword"] = {
  event = { "BufReadPre", "BufNewFile" },
  config = utils.load_conf("editor", "cursor_word"),
  disable = not rvim.plugin.cursorword.active,
}

editor["hrsh7th/vim-eft"] = {
  config = utils.load_conf("editor", "eft"),
  disable = not rvim.plugin.eft.active,
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
