local lang = {}
local conf = require('modules.lang.config')

lang['neovim/nvim-lspconfig'] = {event = 'BufReadPre', config = conf.nvim_lsp}

lang['glepnir/lspsaga.nvim'] = {cmd = 'Lspsaga'}

lang['nvim-treesitter/nvim-treesitter'] =
    {event = 'BufRead', after = 'telescope.nvim', config = conf.nvim_treesitter}

lang['nvim-treesitter/nvim-treesitter-textobjects'] =
    {after = 'nvim-treesitter'}

lang['mfussenegger/nvim-dap'] = {config = conf.dap}

lang['rcarriga/nvim-dap-ui'] = {config = conf.dap_ui}

return lang

