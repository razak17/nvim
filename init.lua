local fn, cmd = vim.fn, vim.cmd

if fn.filereadable(fn.fnamemodify("~/.config/rvim/external/utils/.vimrc.local", ":p")) > 0 then
  cmd [[source ~/.config/rvim/external/utils/.vimrc.local]]
end

-- Load Modules
require "core"
