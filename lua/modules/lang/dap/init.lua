require('modules.lang.dap.javascript')
require('modules.lang.dap.python')
require('modules.lang.dap.go')

vim.fn.sign_define("DapBreakpoint",
                   {text = "🛑", texthl = "", linehl = "", numhl = ""})
