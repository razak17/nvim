local conf = require('modules.editor.config')
local editor = {}

editor['rhysd/accelerated-jk'] = {opt = true, event = "VimEnter"}

editor['tpope/vim-surround'] = {event = {'BufReadPre', 'BufNewFile'}}

editor['norcalli/nvim-colorizer.lua'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.nvim_colorizer
}

editor['monaqa/dial.nvim'] = {event = {'BufReadPre', 'BufNewFile'}}

editor['itchyny/vim-cursorword'] = {event = 'VimEnter'}

editor['b3nj5m1n/kommentary'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = function()
    require('kommentary.config').configure_language("default", {
      prefer_single_line_comments = true
    })
  end
}

editor['windwp/nvim-autopairs'] = {
  event = 'InsertEnter',
  config = function()
    require('nvim-autopairs').setup({
      disable_filetype = {"TelescopePrompt", "vim", "lua", "c", "cpp"}
    })
  end
}

editor['Raimondi/delimitMate'] = {
  event = 'InsertEnter',
  config = conf.delimimate
}

editor['romainl/vim-cool'] = {
  event = {'BufRead', 'BufNewFile'},
  config = function()
    vim.g.CoolTotalMatches = 1
  end
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
