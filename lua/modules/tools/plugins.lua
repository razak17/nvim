local tools = {}
local conf = require('modules.tools.config')

tools['tpope/vim-fugitive'] = {event = 'VimEnter', disable = not rvim.plugin.fugitive.active}

tools['mbbill/undotree'] = {cmd = "UndotreeToggle", disable = not rvim.plugin.undotree.active}

tools['airblade/vim-rooter'] = {
  config = function()
    vim.g.rooter_silent_chdir = 1
    vim.g.rooter_patterns = {
      '=nvim',
      '.git',
      '.gitignore',
      'lua',
      "_darcs",
      ".hg",
      ".bzr",
      ".svn",
      "Makefile",
      "package.json",
      "package-lock.json",
    }
  end,
  disable = not rvim.plugin.rooter.active,
}

tools['npxbr/glow.nvim'] = {
  run = ":GlowInstall",
  branch = "main",
  disable = not rvim.plugin.glow.active,
}

tools['kkoomen/vim-doge'] = {
  run = ':call doge#install()',
  config = function()
    vim.g.doge_mapping = '<Leader>vD'
  end,
  disable = not rvim.plugin.doge.active,
}

tools['numToStr/FTerm.nvim'] = {
  event = {"BufWinEnter"},
  config = conf.fterm,
  disable = not rvim.plugin.fterm.active,
}

tools['MattesGroeger/vim-bookmarks'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = conf.bookmarks,
  disable = not rvim.plugin.bookmarks.active,
}

tools['diepm/vim-rest-console'] = {event = 'VimEnter', disable = not rvim.plugin.restconsole.active}

tools['iamcco/markdown-preview.nvim'] = {
  config = function()
    vim.g.mkdp_auto_start = 0
  end,
  run = 'cd app && yarn install',
  cmd = 'MarkdownPreview',
  ft = 'markdown',
  disable = not rvim.plugin.markdown_preview.active,
}

tools['brooth/far.vim'] = {
  event = {'BufReadPre', 'BufNewFile'},
  config = function()
    vim.g['far#source'] = 'rg'
    vim.g['far#enable_undo'] = 1
  end,
  disable = not rvim.plugin.far.active,
}

tools['kristijanhusak/vim-dadbod-ui'] = {
  cmd = {'DBUIToggle', 'DBUIAddConnection', 'DBUI', 'DBUIFindBuffer', 'DBUIRenameBuffer'},
  config = conf.vim_dadbod_ui,
  requires = {
    {'tpope/vim-dadbod', opt = true},
    {'kristijanhusak/vim-dadbod-completion', opt = true},
  },
  disable = not rvim.plugin.dadbod.active,
}

return tools
