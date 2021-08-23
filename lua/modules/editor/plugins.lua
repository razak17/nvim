local conf = require "modules.editor.config"

local editor = {}

local function load_conf(name)
  return require(string.format("modules.editor.%s", name))
end

editor["rhysd/accelerated-jk"] = {
  opt = true,
  event = { "BufWinEnter" },
  config = load_conf "ajk",
  disable = not rvim.plugin.accelerated_jk.active and not rvim.plugin.SANE.active,
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
  config = conf.dial,
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
  config = conf.vim_cursorword,
  disable = not rvim.plugin.cursorword.active,
}

editor["hrsh7th/vim-eft"] = {
  config = load_conf "eft",
  disable = not rvim.plugin.eft.active,
}

editor["norcalli/nvim-colorizer.lua"] = {
  event = { "BufReadPre", "BufNewFile" },
  config = conf.nvim_colorizer,
  disable = not rvim.plugin.colorizer.active,
}

editor["Raimondi/delimitMate"] = {
  event = { "BufReadPre", "BufNewFile" },
  config = conf.delimitmate,
  disable = not rvim.plugin.delimitmate.active,
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
  config = conf.kommentary,
  disable = not rvim.plugin.SANE.active,
}

return editor
