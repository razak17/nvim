local conf = require('modules.aesth.conf')
local aesth = {}

aesth['christianchiarulli/nvcode-color-schemes.vim'] = {
  config = conf.bg
}

aesth['glepnir/galaxyline.nvim'] = {
  branch = 'main',
  config = conf.galaxyline,
  requires = {'kyazdani42/nvim-web-devicons'}
}

aesth['akinsho/nvim-bufferline.lua'] = {
  config = conf.nvim_bufferline,
  requires = {'kyazdani42/nvim-web-devicons'}
}

aesth['glepnir/dashboard-nvim'] = {
  config = conf.dashboard
}

aesth['kyazdani42/nvim-tree.lua'] = {
  cmd = {'NvimTreeToggle','NvimTreeOpen'},
  config = conf.nvim_tree,
  requires = {'kyazdani42/nvim-web-devicons'}
}

aesth['romainl/vim-cool'] = {
  config = function ()
    vim.g.CoolTotalMatches = 1
  end
}

aesth['RRethy/vim-illuminate'] = {
  config = function ()
    vim.g.Illuminate_ftblacklist = { 'javascript', 'typescript', 'jsx', 'tsx', 'html' }
  end
}


return aesth
