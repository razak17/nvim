local dap = require 'dap'
local vnoremap, nnoremap = core.vnoremap, core.nnoremap

require('modules.lang.dap.javascript')
require('modules.lang.dap.python')
require('modules.lang.dap.go')
require('modules.lang.dap.lua]]')

vim.cmd [[packadd nvim-dap]]

vim.fn.sign_define("DapBreakpoint",
  {text = "🛑", texthl = "", linehl = "", numhl = ""})

vim.fn.sign_define("DapStopped",
  {text = "🟢", texthl = "", linehl = "", numhl = ""})

local function set_breakpoint()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end
vnoremap("<localleader>di",
  [[<cmd>lua require'dap.ui.variables'.visual_hover()<CR>]])

nnoremap("<localleader>dB", set_breakpoint)
