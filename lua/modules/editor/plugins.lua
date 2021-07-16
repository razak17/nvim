local conf = require('modules.editor.config')

local editor = {}

editor['rhysd/accelerated-jk'] = {
  opt = true,
  event = {'VimEnter'},
  disable = not core.plugin.accelerated_jk.active and
    not core.plugin.SANE.active,
}

editor['tpope/vim-surround'] = {
  disable = not core.plugin.surround.active and not core.plugin.SANE.active,
}

editor['monaqa/dial.nvim'] = {
  event = 'BufReadPre',
  config = conf.dial,
  disable = not core.plugin.dial.active,
}

editor['junegunn/vim-easy-align'] = {
  event = {'BufReadPre', 'BufNewFile'},
  disable = not core.plugin.easy_align.active,
}

editor['razak17/vim-cursorword'] = {
  config = conf.vim_cursorword,
  disable = not core.plugin.cursorword.active and not core.plugin.SANE.active,
}

editor['hrsh7th/vim-eft'] = {
  config = function() vim.g.eft_ignorecase = true end,
  disable = not core.plugin.eft.active,
}

editor['norcalli/nvim-colorizer.lua'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.nvim_colorizer,
  disable = not core.plugin.colorizer.active,
}

editor['Raimondi/delimitMate'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.delimitmate,
  disable = not core.plugin.delimitmate.active,
}

editor['romainl/vim-cool'] = {
  config = function() vim.g.CoolTotalMatches = 1 end,
  disable = not core.plugin.cool.active and not core.plugin.SANE.active,
}

editor['arecarn/vim-fold-cycle'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = function()
    vim.g.fold_cycle_default_mapping = 0
    vim.g.fold_cycle_toggle_max_open = 0
    vim.g.fold_cycle_toggle_max_close = 0
  end,
  disable = not core.plugin.fold_cycle.active,
}

editor['b3nj5m1n/kommentary'] = {
  event = {"BufWinEnter"},
  config = conf.kommentary,
  disable = not core.plugin.SANE.active,
}

return editor
