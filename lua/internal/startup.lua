local g = vim.g
local M = {}

local disable_builtin_plugins = function()
  g["loaded_gzip"] = 1
  g["loaded_tar"] = 1
  g["loaded_tarPlugin"] = 1
  g["loaded_zip"] = 1
  g["loaded_zipPlugin"] = 1
  g["loaded_getscript"] = 1
  g["loaded_getscriptPlugin"] = 1
  g["loaded_vimball"] = 1
  g["loaded_vimballPlugin"] = 1
  g["loaded_matchit"] = 1
  g["loaded_matchparen"] = 1
  g["loaded_2html_plugin"] = 1
  g["loaded_logiPat"] = 1
  g["loaded_rrhelper"] = 1
  g["loaded_netrw"] = 1
  g["loaded_netrwPlugin"] = 1
  g["loaded_netrwSettings"] = 1
  g["loaded_netrwFileHandlers"] = 1
  g["loaded_fzf"] = 1
  g["loaded_skim"] = 1
  g["loaded_tutor_mode_plugin"] = 1
end

local disable_providers = function()
  g["loaded_python_provider"] = 0
  g["loaded_ruby_provider"] = 0
  g["loaded_perl_provider"] = 0
end

local set_host_prog = function()
  g["python3_host_prog"] = r17._python3 .. "bin" .. r17.__path_sep .. "python"
  g["node_host_prog"] = r17._node
end

local global_utils = function()
  g["floating_window_winblend"] = 0
  g["floating_window_scaling_factor"] = 0.8
  g["neovim_remote"] = 1
  g["rg_derive_root"] = true
end

local map_leader = function()
  g["mapleader"] = " "
  g["maplocalleader"] = " "
  g["completion_confirm_key"] = ""
end

M.init = function()
  disable_builtin_plugins()
  disable_providers()
  set_host_prog()
  global_utils()
  map_leader()
end

return M
