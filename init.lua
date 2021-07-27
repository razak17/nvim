local fn, cmd = vim.fn, vim.cmd

if fn.filereadable(fn.fnamemodify("~/.vimrc.local", ":p")) > 0 then
  cmd [[source ~/.vimrc.local]]
end

-- Load Modules
require "globals"
require "defaults"
require "core"
