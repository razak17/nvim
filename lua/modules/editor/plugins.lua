local conf = require('modules.editor.conf')
local editor = {}

editor['norcalli/nvim-colorizer.lua'] = {
  -- ft = { 'html','css','sass','vim','typescript','typescriptreact'},
  config = conf.nvim_colorizer
}

editor['windwp/nvim-autopairs'] = {
  config = conf.autopairs
}

editor['voldikss/vim-floaterm'] = {
  config = conf.floaterm
}

editor['tpope/vim-fugitive'] = {
  config = conf.fugitive
}

editor['b3nj5m1n/kommentary'] = {
  config = conf.kommentary
}


return editor

