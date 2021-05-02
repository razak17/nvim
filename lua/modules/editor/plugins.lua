local conf = require('modules.editor.config')
local editor = {}

editor['phaazon/hop.nvim'] = {event = {'BufReadPre', 'BufNewFile'}, as = 'hop'}

editor['norcalli/nvim-colorizer.lua'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.nvim_colorizer
}

editor['rhysd/accelerated-jk'] = {
  event = {'BufReadPre', 'BufNewFile'},
  opt = true
}

editor['monaqa/dial.nvim'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.dial
}

editor['b3nj5m1n/kommentary'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.kommentary
}

editor['windwp/nvim-autopairs'] = {
  event = 'InsertEnter',
  config = conf.autopairs
}

editor['Raimondi/delimitMate'] = {
  event = 'InsertEnter',
  config = conf.delimimate
}

editor['hrsh7th/vim-eft'] = {
  event = {'BufReadPre', 'BufNewFile'},
  opt = true,
  config = function()
    vim.g.eft_ignorecase = true
  end
}

editor['windwp/nvim-ts-autotag'] = {
  event = {'BufReadPre', 'BufNewFile'},
  opt = true,
  after = 'nvim-treesitter',
  config = function()
    require('nvim-ts-autotag').setup()
  end
}

return editor
