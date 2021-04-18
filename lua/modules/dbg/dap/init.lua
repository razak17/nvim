require('modules.dbg.dap.javascript')
require('modules.dbg.dap.python')
require('modules.dbg.dap.go')

vim.fn.sign_define("DapBreakpoint",
                   {text = "🛑", texthl = "", linehl = "", numhl = ""})
