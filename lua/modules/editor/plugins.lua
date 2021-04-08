local conf = require('modules.editor.config')
local editor = {}

editor['tpope/vim-surround'] = {}

editor['phaazon/hop.nvim'] = {as = 'hop'}

editor['rhysd/accelerated-jk'] = {opt = true}

editor['monaqa/dial.nvim'] = {config = conf.dial}

editor['windwp/nvim-autopairs'] = {config = conf.autopairs}

editor['AndrewRadev/tagalong.vim'] = {config = conf.tagalong}

editor['norcalli/nvim-colorizer.lua'] = {config = conf.nvim_colorizer}

editor['b3nj5m1n/kommentary'] = {
  config = function()
    require('kommentary.config').configure_language("default", {
      prefer_single_line_comments = true
    })
  end
}

editor['hrsh7th/vim-eft'] = {
  opt = true,
  config = function()
    vim.g.eft_ignorecase = true
  end
}

editor['MattesGroeger/vim-bookmarks'] = {
  config = function()
    vim.g.bookmark_no_default_key_mappings = 1
    vim.g.bookmark_sign = ''
  end
}

return editor

