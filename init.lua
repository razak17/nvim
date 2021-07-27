local function load_runtime()
  vim.cmd [[
  "set packpath-=~/.config/nvim
  "set packpath-=~/.config/nvim/after
  "set packpath-=~/.local/share/nvim/site
  set packpath^=~/.local/share/vim/site
  set packpath^=~/.config/rvim

  set runtimepath=$XDG_CONFIG_HOME/nvim
  set runtimepath+=$XDG_CONFIG_HOME/nvim
  set runtimepath+=$XDG_CONFIG_HOME/nvim/after
  set runtimepath+=$XDG_DATA_HOME/nvim/site
  set runtimepath+=$XDG_DATA_HOME/nvim/pack/packer/start
  set runtimepath+=$XDG_DATA_HOME/nvim/pack/packer/opt
  set runtimepath+=$VIMRUNTIME
  ]]
end
-- Load Modules:
load_runtime()
require 'globals'
require 'defaults'
require 'core'
