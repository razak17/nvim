local g, fn, cmd = vim.g, vim.fn, vim.cmd

if fn.filereadable(fn.fnamemodify("~/.config/rvim/external/utils/.vimrc.local", ":p")) > 0 then
  cmd [[source ~/.config/rvim/external/utils/.vimrc.local]]
end

g.open_command = g.os == "Darwin" and "open" or "xdg-open"
g.vimfiles_path = vim.fn.expand "<sfile>:h"
g.plugin_config_dir = g.vimfiles_path .. '/lua/modules'

-- Load Modules
require "core"
