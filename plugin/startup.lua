local g = vim.g

local set_host_prog = function()
  g["python3_host_prog"] = rvim._python3 .. "bin/python"
  g["node_host_prog"] = rvim._node
end

local global_utils = function()
  g["floating_window_winblend"] = 0
  g["floating_window_scaling_factor"] = 0.8
  g["neovim_remote"] = 1
  g["rg_derive_root"] = true
end

local map_leader = function()
  g["mapleader"] = rvim.utils.leader_key
  g["maplocalleader"] = rvim.utils.leader_key
end

set_host_prog()
global_utils()
map_leader()
