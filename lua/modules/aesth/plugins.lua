local conf = require('modules.aesth.config')
local aesth = {}

aesth['glepnir/dashboard-nvim'] = {config = conf.dashboard}

aesth['razak17/zephyr-nvim'] = {config = conf.bg}

aesth['glepnir/galaxyline.nvim'] = {
  branch = 'main',
  config = conf.galaxyline,
  requires = {'kyazdani42/nvim-web-devicons'}
}

aesth['akinsho/nvim-bufferline.lua'] = {
  config = conf.nvim_bufferline,
  requires = {'kyazdani42/nvim-web-devicons'}
}

aesth['romainl/vim-cool'] = {
  config = function()
    vim.g.CoolTotalMatches = 1
  end
}

aesth['lewis6991/gitsigns.nvim'] = {
  event = {'BufRead', 'BufNewFile'},
  config = conf.gitsigns,
  requires = 'nvim-lua/plenary.nvim'
}

aesth['kyazdani42/nvim-tree.lua'] = {
  cmd = {'NvimTreeToggle', 'NvimTreeOpen'},
  config = conf.nvim_tree,
  requires = {'kyazdani42/nvim-web-devicons'}
}

aesth['p00f/nvim-ts-rainbow'] = {after = 'nvim-treesitter'}

return aesth
