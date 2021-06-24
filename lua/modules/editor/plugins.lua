local conf = require('modules.editor.config')

local editor = {}

editor['rhysd/accelerated-jk'] = {opt = true, event = {'VimEnter'}}

editor['monaqa/dial.nvim'] = {event = 'BufReadPre'}

editor['tpope/vim-surround'] = {event = {'BufReadPre', 'BufNewFile'}}

editor['razak17/vim-cursorword'] = {
  event = {'BufReadPre', 'BufNewFile', config = conf.cursorword},
}

editor['hrsh7th/vim-eft'] = {
  opt = true,
  config = function() vim.g.eft_ignorecase = true end,
}

-- editor['winston0410/range-highlight.nvim'] =  {
--   requires = {'winston0410/cmd-parser.nvim'},
--   config = function()
--     require'range-highlight'.setup{}
--   end
-- }

editor['norcalli/nvim-colorizer.lua'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.nvim_colorizer,
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
}

editor['b3nj5m1n/kommentary'] = {
  config = function()
    require('kommentary.config').configure_language('default', {
      prefer_single_line_comments = true,
    })
    require('kommentary.config').configure_language('zsh', {
      single_line_comment_string = "#",
    })
    require('kommentary.config').configure_language('sh', {
      single_line_comment_string = "#",
    })
  end,
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
