local conf = require('modules.aesth.config')
local aesth = {}

aesth['glepnir/dashboard-nvim'] = {event = "VimEnter", config = conf.dashboard}

aesth['razak17/zephyr-nvim'] = {config = [[vim.cmd('colo zephyr')]]}

aesth['itchyny/vim-cursorword'] = {event = {'BufReadPre', 'BufNewFile'}}

aesth['lukas-reineke/indent-blankline.nvim'] =
    {event = 'VimEnter', branch = 'lua', config = conf.indent_blankline}

aesth['akinsho/nvim-bufferline.lua'] = {
  event = "VimEnter",
  config = conf.nvim_bufferline,
  requires = 'kyazdani42/nvim-web-devicons'
}

aesth['kyazdani42/nvim-tree.lua'] = {
  config = conf.nvim_tree,
  requires = 'kyazdani42/nvim-web-devicons'
}

aesth['glepnir/galaxyline.nvim'] = {
  branch = 'main',
  config = conf.galaxyline,
  requires = 'kyazdani42/nvim-web-devicons'
}

aesth['romainl/vim-cool'] = {
  event = {'BufRead', 'BufNewFile'},
  config = function()
    vim.g.CoolTotalMatches = 1
  end
}

aesth['lewis6991/gitsigns.nvim'] = {
  event = {'BufRead', 'BufNewFile'},
  config = conf.gitsigns,
  requires = {{'nvim-lua/plenary.nvim', opt = true}}
}

return aesth
