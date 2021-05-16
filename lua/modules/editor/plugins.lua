local conf = require('modules.editor.config')
local editor = {}

editor['norcalli/nvim-colorizer.lua'] = {config = conf.nvim_colorizer}

editor['rhysd/accelerated-jk'] = {opt = true}

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
  opt = true,
  config = function()
    vim.g.eft_ignorecase = true
  end
}

editor['windwp/nvim-ts-autotag'] = {
  opt = true,
  event = "InsertLeavePre",
  after = 'nvim-treesitter'
}

editor['kkoomen/vim-doge'] = {
  run = ':call doge#install()',
  config = function()
    vim.g.doge_mapping = '<Leader>D'
  end
}

return editor
