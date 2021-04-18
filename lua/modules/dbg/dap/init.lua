require('modules.dbg.dap.typescript')
require('modules.dbg.dap.javascript')
require('modules.dbg.dap.python')

vim.fn.sign_define("DapBreakpoint",
                   {text = "🛑", texthl = "", linehl = "", numhl = ""})
