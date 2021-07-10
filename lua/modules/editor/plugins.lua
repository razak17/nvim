local conf = require('modules.editor.config')

local editor = {}

editor['rhysd/accelerated-jk'] = {
  opt = true,
  event = {'VimEnter'},
  disable = not core.active.accelerated_jk,
}

editor['tpope/vim-surround'] = {event = {'BufReadPre', 'BufNewFile'}}

editor['monaqa/dial.nvim'] = {event = 'BufReadPre', config = conf.dial}

editor['junegunn/vim-easy-align'] = {
  event = {'BufReadPre', 'BufNewFile'},
  disable = not core.active.easy_align,
}

editor['razak17/vim-cursorword'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.cursorword,
  disable = not core.active.cursorword,
}

editor['hrsh7th/vim-eft'] = {
  opt = true,
  config = function() vim.g.eft_ignorecase = true end,
  disable = not core.active.eft,
}

editor['norcalli/nvim-colorizer.lua'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.nvim_colorizer,
  disable = not core.active.colorizer,
}

editor['Raimondi/delimitMate'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.delimimate,
}

editor['romainl/vim-cool'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = function() vim.g.CoolTotalMatches = 1 end,
}

-- editor['kkoomen/vim-doge'] = {
--   run = ':call doge#install()',
--   config = function()
--     vim.g.doge_mapping = '<Leader>vD'
--   end
-- }

editor['arecarn/vim-fold-cycle'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = function()
    vim.g.fold_cycle_default_mapping = 0
    vim.g.fold_cycle_toggle_max_open = 0
    vim.g.fold_cycle_toggle_max_close = 0
  end,
  disable = not core.active.fold_cycle,
}

editor['b3nj5m1n/kommentary'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.kommentary,
}

editor['windwp/nvim-autopairs'] = {
  event = 'InsertEnter',
  config = function()
    require('nvim-autopairs').setup({
      disable_filetype = {'TelescopePrompt', 'vim'},
    })
  end,
}

return editor
