local conf = require('modules.editor.config')

local editor = {}

editor['rhysd/accelerated-jk'] = {
  opt = true,
  event = {"BufWinEnter"},
  disable = not rvim.plugin.accelerated_jk.active and not rvim.plugin.SANE.active,
}

editor['tpope/vim-surround'] = {
  config = function()
    rvim.xmap("S", "<Plug>VSurround")
    rvim.xmap("S", "<Plug>VSurround")
  end,
  disable = not rvim.plugin.surround.active,
}

editor['monaqa/dial.nvim'] = {
  event = {"BufWinEnter"},
  config = conf.dial,
  disable = not rvim.plugin.dial.active,
}

editor['junegunn/vim-easy-align'] = {
  event = {'BufReadPre', 'BufNewFile'},
  disable = not rvim.plugin.easy_align.active,
}

editor['razak17/vim-cursorword'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.vim_cursorword,
  disable = not rvim.plugin.cursorword.active,
}

editor['hrsh7th/vim-eft'] = {
  config = function() vim.g.eft_ignorecase = true end,
  disable = not rvim.plugin.eft.active,
}

editor['norcalli/nvim-colorizer.lua'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.nvim_colorizer,
  disable = not rvim.plugin.colorizer.active,
}

editor['Raimondi/delimitMate'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.delimitmate,
  disable = not rvim.plugin.delimitmate.active,
}

editor['romainl/vim-cool'] = {
  config = function() vim.g.CoolTotalMatches = 1 end,
  disable = not rvim.plugin.cool.active,
}

editor['arecarn/vim-fold-cycle'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = function()
    vim.g.fold_cycle_default_mapping = 0
    vim.g.fold_cycle_toggle_max_open = 0
    vim.g.fold_cycle_toggle_max_close = 0
  end,
  disable = not rvim.plugin.fold_cycle.active,
}

editor['b3nj5m1n/kommentary'] = {
  event = {"BufWinEnter"},
  config = conf.kommentary,
  disable = not rvim.plugin.SANE.active,
}

return editor
