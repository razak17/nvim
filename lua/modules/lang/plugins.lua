local lang = {}
local conf = require('modules.lang.config')

lang['mfussenegger/nvim-dap'] = {config = conf.dap}

lang['rcarriga/nvim-dap-ui'] = {config = conf.dap_ui}

lang['glepnir/lspsaga.nvim'] = {event = {'BufRead'}, cmd = 'Lspsaga'}

lang['kevinhwang91/nvim-bqf'] = {event = {'BufReadPre'}, config = conf.bqf}

lang['neovim/nvim-lspconfig'] = {event = {'BufRead'}, config = conf.nvim_lsp}

lang['nvim-treesitter/nvim-treesitter'] =
    {
      event = {'VimEnter'},
      after = 'telescope.nvim',
      run = ':TSUpdate',
      config = conf.treesitter
    }

lang['liuchengxu/vista.vim'] = {
  event = {'BufRead'},
  cmd = 'Vista',
  config = conf.vim_vista
}

lang['simrat39/symbols-outline.nvim'] = {
  event = {'BufRead'},
  cmd = 'SymbolsOutline',
  config = conf.symbols
}

lang['folke/trouble.nvim'] = {
  event = {'BufRead'},
  requires = "kyazdani42/nvim-web-devicons",
  config = conf.trouble
}

lang['windwp/nvim-ts-autotag'] = {
  opt = true,
  after = 'nvim-treesitter',
  event = "InsertLeavePre",
  config = function()
    require('nvim-ts-autotag').setup({
      filetypes = {'html', 'typescriptreact', 'javascriptreact'}
    })
  end
}

lang['p00f/nvim-ts-rainbow'] = {
  after = 'nvim-treesitter',
  config = function()
    vim.api.nvim_exec([[
      hi rainbowcol1 guifg=#ec5767
      hi rainbowcol2 guifg=#008080
      hi rainbowcol3 guifg=#d16d9e
      hi rainbowcol4 guifg=#e7e921
      hi rainbowcol5 guifg=#689d6a
      hi rainbowcol6 guifg=#d67d4e
      hi rainbowcol7 guifg=#7ec0ee
    ]], false)
  end
}

return lang

