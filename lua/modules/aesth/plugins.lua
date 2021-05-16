local conf = require('modules.aesth.config')
local aesth = {}

aesth['razak17/zephyr-nvim'] = {config = conf.bg}

aesth['glepnir/dashboard-nvim'] = {config = conf.dashboard}

aesth['itchyny/vim-cursorword'] = {config = conf.vim_cursorwod}

aesth['lukas-reineke/indent-blankline.nvim'] =
    {event = 'BufRead', branch = 'lua', config = conf.indent_blankline}

aesth['akinsho/nvim-bufferline.lua'] = {
  config = conf.nvim_bufferline,
  requires = 'kyazdani42/nvim-web-devicons'
}

aesth['romainl/vim-cool'] = {
  event = {'BufRead', 'BufNewFile'},
  config = function()
    vim.g.CoolTotalMatches = 1
  end
}

aesth['glepnir/galaxyline.nvim'] = {
  branch = 'main',
  config = conf.galaxyline,
  requires = 'kyazdani42/nvim-web-devicons'
}

aesth['lewis6991/gitsigns.nvim'] = {
  event = {'BufRead', 'BufNewFile'},
  config = conf.gitsigns,
  requires = {'nvim-lua/plenary.nvim', opt = true}

}

aesth['kyazdani42/nvim-tree.lua'] = {
  cmd = {'NvimTreeToggle', 'NvimTreeOpen'},
  config = conf.nvim_tree,
  requires = 'kyazdani42/nvim-web-devicons'
}

return aesth
