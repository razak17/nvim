local conf = require('modules.editor.config')
local editor = {}

editor['phaazon/hop.nvim'] = {as = 'hop'}

editor['rhysd/accelerated-jk'] = {opt = true}

editor['monaqa/dial.nvim'] = {config = conf.dial}

editor['b3nj5m1n/kommentary'] = {config = conf.kommentary}

editor['windwp/nvim-autopairs'] = {config = conf.autopairs}

editor['norcalli/nvim-colorizer.lua'] = {
  ft = {'html', 'lua', 'css', 'sass', 'vim', 'typescript', 'typescriptreact'},
  config = conf.nvim_colorizer
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
  after = 'nvim-treesitter',
  config = function()
    require('nvim-ts-autotag').setup()
  end
}

return editor
