local conf = require('modules.aesth.config')
local aesth = {}

aesth['junegunn/goyo.vim'] = {}

aesth['glepnir/indent-guides.nvim'] = {
  event = 'BufRead',
  config = conf.indent
}

aesth['glepnir/dashboard-nvim'] = {config = conf.dashboard}

aesth['christianchiarulli/nvcode-color-schemes.vim'] = {config = conf.bg}

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

aesth['RRethy/vim-illuminate'] = {
  config = function()
    vim.g.Illuminate_ftblacklist = {
      'javascript',
      'python',
      'typescript',
      'jsx',
      'tsx',
      'html'
    }
  end
}

aesth['lewis6991/gitsigns.nvim'] = {
  event = {'BufRead', 'BufNewFile'},
  config = conf._gitsigns,
  requires = {'nvim-lua/plenary.nvim', opt = true}
}

aesth['kyazdani42/nvim-tree.lua'] = {
  cmd = {'NvimTreeToggle', 'NvimTreeOpen'},
  config = conf.nvim_tree,
  requires = {'kyazdani42/nvim-web-devicons'}
}

return aesth
