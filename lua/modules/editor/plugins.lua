local conf = require('modules.editor.config')
local editor = {}

editor['rhysd/accelerated-jk'] = {opt = true}

editor['tpope/vim-surround'] = {event = {'BufReadPre', 'BufNewFile'}}

editor['norcalli/nvim-colorizer.lua'] = {
  ft = {'typescript', 'lua', 'css', 'yaml', 'tmux'},
  config = conf.nvim_colorizer
}

editor['monaqa/dial.nvim'] = {event = {'BufReadPre', 'BufNewFile'}}

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

editor['kkoomen/vim-doge'] = {
  run = ':call doge#install()',
  config = function()
    vim.g.doge_mapping = '<Leader>D'
  end
}

return editor
