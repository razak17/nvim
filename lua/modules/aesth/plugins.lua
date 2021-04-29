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
  after = 'plenary.nvim',
  config = conf.gitsigns
}

aesth['kyazdani42/nvim-tree.lua'] = {
  cmd = {'NvimTreeToggle', 'NvimTreeOpen'},
  config = conf.nvim_tree,
  requires = {'kyazdani42/nvim-web-devicons'}
}

aesth['p00f/nvim-ts-rainbow'] = {
  after = 'nvim-treesitter',
  config = function()
    vim.api.nvim_exec([[
      hi rainbowcol1 guifg=#ec5767
      hi rainbowcol2 guifg=#008080
      hi rainbowcol3 guifg=#d16d9e
      hi rainbowcol4 guifg=#e7e921
      hi rainbowcol5 guifg=#689d6a
      hi rainbowcol6 guifg=#d65d0e
      hi rainbowcol7 guifg=#7ec0ee
    ]], false)
  end
}

return aesth
