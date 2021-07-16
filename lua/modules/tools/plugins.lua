local tools = {}
local conf = require('modules.tools.config')

-- tools['tjdevries/astronauta.nvim'] = {}

tools['tpope/vim-fugitive'] = {
  event = 'VimEnter',
  disable = not core.plugin.fugitive.active,
}

tools['mbbill/undotree'] = {
  cmd = "UndotreeToggle",
  disable = not core.plugin.undotree.active,
}

tools['airblade/vim-rooter'] = {
  event = {"BufWinEnter"},
  config = function()
    vim.g.rooter_silent_chdir = 1
    vim.g.rooter_patterns = {'^.config', '.git', '.gitignore'}
  end,
}

tools['npxbr/glow.nvim'] = {
  run = ":GlowInstall",
  branch = "main",
  disable = not core.plugin.glow.active,
}

tools['kkoomen/vim-doge'] = {
  run = ':call doge#install()',
  config = function() vim.g.doge_mapping = '<Leader>vD' end,
  disable = not core.plugin.doge.active,
}

tools['numToStr/FTerm.nvim'] = {
  event = {"BufWinEnter"},
  config = conf.fterm,
  disable = not core.plugin.fterm.active and not core.plugin.SANE.active,
}

tools['MattesGroeger/vim-bookmarks'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.bookmarks,
  disable = not core.plugin.bookmarks.active,
}

tools['diepm/vim-rest-console'] = {
  event = 'VimEnter',
  disable = not core.plugin.restconsole.active,
}

tools['iamcco/markdown-preview.nvim'] = {
  ft = 'markdown',
  config = function() vim.g.mkdp_auto_start = 0 end,
  disable = not core.plugin.markdown_preview.active,
}

tools['brooth/far.vim'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = function()
    vim.g['far#source'] = 'rg'
    vim.g['far#enable_undo'] = 1
  end,
  disable = not core.plugin.far.active,
}

tools['kristijanhusak/vim-dadbod-ui'] = {
  cmd = {
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUI',
    'DBUIFindBuffer',
    'DBUIRenameBuffer',
  },
  config = conf.vim_dadbod_ui,
  requires = {
    {'tpope/vim-dadbod', opt = true},
    {'kristijanhusak/vim-dadbod-completion', opt = true},
  },
  disable = not core.plugin.dadbod.active,
}

return tools
