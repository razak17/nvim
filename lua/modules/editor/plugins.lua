local conf = require('modules.editor.config')
local editor = {}

editor['monaqa/dial.nvim'] = {event = 'BufReadPre'}

-- editor['itchyny/vim-cursorword'] = {event = 'BufRead'}

editor['rhysd/accelerated-jk'] = {opt = true, event = "VimEnter"}

editor['tpope/vim-surround'] = {event = {'BufReadPre', 'BufNewFile'}}

editor['norcalli/nvim-colorizer.lua'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.nvim_colorizer
}

editor['Raimondi/delimitMate'] = {
  event = 'InsertEnter'
  -- config = conf.delimimate
}

editor['b3nj5m1n/kommentary'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = function()
    require('kommentary.config').configure_language("default", {
      prefer_single_line_comments = true
    })
  end
}

editor['romainl/vim-cool'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = function()
    vim.g.CoolTotalMatches = 1
  end
}

return editor
